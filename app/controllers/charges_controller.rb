class ChargesController < ApplicationController
  def init_checkout
    products = []
    product_info = {
      'home energy' => {
        'one_time' => {
          'month' => 'price_1JHuI7L1SWXeEQ2feQqPHIOL',
          'quarter' => 'price_1JcBukL1SWXeEQ2fZnNENAWK',
          'year' => 'price_1JcBv2L1SWXeEQ2fOO9EQZHQ'
        },
        'recurring' => {
          'month' => 'price_1IW12sL1SWXeEQ2fPa1BkryP',
          'quarter' => 'price_1IW13LL1SWXeEQ2ft4svzOQI',
          'year' => 'price_1IW13tL1SWXeEQ2fIzGnG7ib'
        }
      },
      'car travel' => {
        'one_time' => {
          'month' => 'price_1IQy2PL1SWXeEQ2fxHGWf41O',
          'quarter' => 'price_1JcC33L1SWXeEQ2fjLsFf9mA',
          'year' => 'price_1JHuEpL1SWXeEQ2fuFAIsJFA'
        },
        'recurring' => {
          'month' => 'price_1IQy23L1SWXeEQ2fgJFdSDUO',
          'quarter' => 'price_1IQy23L1SWXeEQ2fHzm9oQl0',
          'year' => 'price_1JHuEpL1SWXeEQ2fuFAIsJFA'
        }
      },
      'air travel' => {
        'one_time' => {
          'month' => 'price_1JQueHL1SWXeEQ2fMkllhTdA',
          'quarter' => 'price_1JcC4NL1SWXeEQ2foH7qYmPd',
          'year' => 'price_1JcC4iL1SWXeEQ2fGWXPXkLv'
        },
        'recurring' => {
          'month' => 'price_1JQucnL1SWXeEQ2fIgRYcEvm',
          'quarter' => 'price_1JQudKL1SWXeEQ2fVHEUrFf9',
          'year' => 'price_1JHtmeL1SWXeEQ2ffsYWUBLO'
        }
      }
    }
    payment_mode = 'payment'
    cart_items = CartItem.where(session_id: params[:session], purchased: false)
    cart_items.each do |p|
      if p['offset_type'].nil?
        products << {
          price_data: {
            product: 'prod_J2jl3voKP5Slaa',
            unit_amount: (p['cost'] * 100).to_i,
            currency: 'usd'
          },
          quantity: 1
        }
      else
        puts p.inspect
        puts product_info[p['offset_type']]
        products << { price: product_info[p['offset_type']][p['frequency']][p['offset_interval']], quantity: 1 }
        puts products
        payment_mode = 'subscription' if p['frequency'] == 'recurring'

      end
    end

    @session = Stripe::Checkout::Session.create({
                                                  payment_method_types: ['card'],
                                                  line_items: products,
                                                  mode: payment_mode,
                                                  success_url: 'http://flcf-staging.herokuapp.com/payment-success?checkout_session_id={CHECKOUT_SESSION_ID}',
                                                  cancel_url: 'https://fingerlakesclimatefund.org'
                                                })

    cart_items.update_all(checkout_session_id: @session.id)

    render json: @session
  end

  def manage
    # For demonstration purposes, we're using the Checkout session to retrieve the customer ID.
    # Typically this is stored alongside the authenticated user in your database.
    checkout_session_id = params['sessionId']
    checkout_session = Stripe::Checkout::Session.retrieve(checkout_session_id)

    # This is the URL to which users will be redirected after they are done
    # managing their billing.
    return_url = ENV['DOMAIN']

    session = Stripe::BillingPortal::Session.create({
                                                      customer: checkout_session['customer'],
                                                      return_url: return_url
                                                    })

    render json: session
  end

  def get_session
    session_id = params[:sessionId]

    session = Stripe::Checkout::Session.retrieve(session_id)
    puts session
    render json: session
  end

  def create
    if params[:stripeSession].length > 1
      if user_signed_in?
        current_user.session_id = nil
        current_user.save
      end
      @stat = Stat.all.first
      @offset_data = { pounds: 0, cost: 0, count: 0 }

      @offsets = Offset.where(session_id: params[:stripeSession]).where('purchased = FALSE')
      if @offsets.count > 0
        @offset_data[:ids] = []
        @offsets.each do |o|
          o.purchased = true
          o.email = params[:stripeEmail]
          o.save
          @offset_data[:pounds] = @offset_data[:pounds] + o.pounds
          @offset_data[:cost] = @offset_data[:cost] + o.cost
          @offset_data[:count] = @offset_data[:count] + 1
          @offset_data[:email] = params[:stripeEmail]
          @offset_data[:name] = o.name
          @offset_data[:ids] << o.id
          @stat.increment!(:pounds, o.pounds)
          @stat.increment!(:dollars, o.cost)
        end
        @offset_data[:ids] = @offset_data[:ids].join(',')
      else
        @donation_mode = true
        puts 'its a donation'
      end
      @player = TeamMember.where(email: params[:stripeEmail]).last
      if @player

        @team = Team.find(@player.team_id)
        @team.increment!(:count, @offset_data[:count].to_i)
        @team.increment!(:pounds, @offset_data[:pounds].to_i)
        TeamMailer.send_thanks(@player.email, @player.team).deliver
        @player.increment!(:offsets)
      end
      @individual = Individual.where(email: params[:stripeEmail]).first

      if @individual
        @individual.increment!(:count)
        @individual.increment!(:pounds, @offset_data[:pounds].to_i)
      end
      @teams = Team.all
      @prizes = Prize.where('count > 0')
      count = 0
      @prizes.each do |p|
        count += p.count
      end
      @empties = count * 2

      customer = Stripe::Customer.create(
        email: params[:stripeEmail],
        card: params[:stripeToken]
      )

      charge = Stripe::Charge.create(
        customer: customer.id,
        amount: params[:stripeCharge],
        description: 'Carbon offset',
        currency: 'usd'
      )
      puts charge.inspect
      # send offset info to little green light
      # put this above the offset mailer, in case that runs into a problem
      # only do if live transaction
      if charge['livemode']
        require 'net/http'
        require 'uri'
        require 'json'
        uri = URI.parse('https://sustainabletompkins.littlegreenlight.com/integrations/e43d9598-3876-47a8-9411-9a6afdff1647/listener')
        data = { payment_type: 'Credit Card', email: params[:stripeEmail], amount: params[:stripeCharge].to_i / 100.round(2), name: @offset_data[:name], zip_code: @offset_data[:zip_code] || 12_314, date: Date.today, fund: 'Finger Lakes Climate Fund' }
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.post(uri, data.to_json, { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
      end

      OffsetMailer.send_offset_details(params[:stripeEmail], @offsets).deliver

      @recent_offsets = Offset.where(purchased: :true).order(id: :desc).limit(5)
      @teams = Team.all

      render layout: 'full'

    end
  rescue Stripe::CardError => e
    flash[:error] = e.message
    # fix this so it goes to an error page
    redirect_to '/error'
  end
end
