class ChargesController < ApplicationController
  def init_checkout
    products = []
    product_info = {
      'home energy' => {
        'one_time' => {
          'month' => 'price_1KK7hDL1SWXeEQ2ft1ojQYFW',
          'quarter' => 'price_1KK7hDL1SWXeEQ2fP1DI1amK',
          'year' => 'price_1KK7hDL1SWXeEQ2ff5OUI266'
        },
        'recurring' => {
          'month' => 'price_1KK7hDL1SWXeEQ2fCloc9eyC',
          'quarter' => 'price_1KK7hDL1SWXeEQ2frBEzX54S',
          'year' => 'price_1KK7hDL1SWXeEQ2fXz9rf6N2'
        }
      },
      'car travel' => {
        'one_time' => {
          'month' => 'price_1KK7hWL1SWXeEQ2fPrCS2PrA',
          'quarter' => 'price_1KK7hWL1SWXeEQ2f23cuStwb',
          'year' => 'price_1KK7hWL1SWXeEQ2f5Vepbkjq'
        },
        'recurring' => {
          'month' => 'price_1KK7hWL1SWXeEQ2fab1EMRoI',
          'quarter' => 'price_1KK7hWL1SWXeEQ2f53cyhCed',
          'year' => 'price_1KK7hWL1SWXeEQ2f6pxfY3Oh'
        }
      },
      'air travel' => {
        'one_time' => {
          'month' => 'price_1KK7hLL1SWXeEQ2f6MtnzCse',
          'quarter' => 'price_1KK7hLL1SWXeEQ2fdvO0EUX6',
          'year' => 'price_1KK7hLL1SWXeEQ2fea8at0ng'
        },
        'recurring' => {
          'month' => 'price_1KK7hLL1SWXeEQ2frPNGGgu4',
          'quarter' => 'price_1KK7hLL1SWXeEQ2ftb4gkVv9',
          'year' => 'price_1KK7hLL1SWXeEQ2fiLwH9kJ6'
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
        products << { price: product_info[p['offset_type']][p['frequency']][p['offset_interval']], quantity: 1 }
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
