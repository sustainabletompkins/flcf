class PagesController < ApplicationController
  http_basic_authenticate_with name: 'admin', password: '309NAurora', only: %i[admin list offset_log]

  def payment_success
    puts 'asdkljskldjaklsjdalks'
    if params.has_key?('checkout_session_id')
      # create the offset objects
      @checkout_session = params['checkout_session_id']
      zipcode = nil
      name = nil
      email = nil
      session = Stripe::Checkout::Session.retrieve(@checkout_session)
      if session.payment_intent
        paymentIntent = Stripe::PaymentIntent.retrieve(
          session.payment_intent
        )

        paymentMethod = Stripe::PaymentMethod.retrieve(
          paymentIntent.payment_method
        )
        zipcode = paymentMethod['billing_details']['address']['postal_code']
        name = paymentMethod['billing_details']['name']
        email = paymentMethod['billing_details']['email']
      else
        cards = Stripe::Customer.list_sources(
          session.customer,
          { object: 'card', limit: 3 }
        )
        customer = Stripe::Customer.retrieve(session.customer)
        # TO DO: get zip and name
      end

      region = Region.get_by_zip(zipcode)

      # convert cart items into completed offsets
      CartItem.where(checkout_session_id: @checkout_session).each do |item|
        Offset.create(name: name, user_id: item.user_id, title: item.title, cost: item.cost, pounds: item.pounds, offset_type: item.offset_type, offset_interval: item.offset_interval, zipcode: zipcode, region: region, checkout_session_id: @checkout_session, email: email)
        item.update_attribute(:purchased, true)
      end

      # redirect to index & include checkout session id
      # redirect_to controller: 'pages', action: 'index', checkout_session_id: @checkout_session
      # redirect_to "http://gayn.sg-host.com/?c_id=#{@checkout_session}"
      redirect_to "http://gayn.sg-host.com/?c_id=#{@checkout_session}"

    else
      # there was no checkout session id
      # show them some kind of error
      @app_mode = 'error'
      render 'spa/app'
    end
  end

  def index
    # response.headers['X-FRAME-OPTIONS'] = 'ALLOW-FROM http://gayn.sg-host.com/, https://hyadev.com/'
    if params.has_key?('c_id')
      # user has just completed a checkout
      # handle carbon races and prize wheel\
      @checkout_session = params['c_id']
      # start by getting offsets associated with checkout session
      @offsets = Offset.where(checkout_session_id: @checkout_session)
      zipcode = @offsets.first.zipcode

      # check to see if this region has any prize choices
      # if not, we will later skip prize wheel
      region = Region.get_by_zip(zipcode)
      @has_prize_choices = region && region.prizes.where('count > 0').first.present?
      if @has_prize_choices
        @prizes = region.prizes.where('count > 0')
        count = 0
        @prizes.each do |p|
          count += p.count
        end
        @empties = count * 4
      end

      # does this email address already belong to a team?  if so, automatically assign offsets to that team
      @teams = Team.all
      team_member = TeamMember.where(email: @offsets.first.email).order('updated_at DESC').first
      player = Individual.where(email: @offsets.first.email).first
      if team_member.present?
        @team = team_member.team
        @offsets.update_all(team_id: @team.id)
      elsif player.present?
        @team = player
        @offsets.update_all(individual_id: @player.id)
      end

      # set app to carbon race mode
      @app_mode = 'carbon races'
    else
      @app_mode = 'calculator'
    end

    render 'spa/app'
  end

  def update
    @page = Page.find(params[:id])
    if @page.update_attributes(page_params)
      render 'saved'
    else
      render 'edit'
    end
  end

  def create
    @page = Page.new(page_params)
    @page.slug = params[:page][:title].downcase.gsub(' ', '-')
    if @page.save
      @url = 'http://fingerlakesclimatefund.org/pages/' + @page.slug
      render 'created'
    else
      render 'error'
    end
  end

  def admin
    @prizes = PrizeWinner.where.not(email: nil).order(created_at: :asc).last(15).reverse
    @prize_list = Prize.where(region_id: 1)
    @offsetters = Offsetter.all
    @teams = Team.all
    @awardees = Awardee.all
    @individuals = Individual.all.order(pounds: :desc)
    @message_templates = MessageTemplate.all
    @teams = Team.all.order(pounds: :desc)
    @stat = Stat.find(1)
    render layout: 'full'
  end

  def prize_wheel
    set_meta_tags title: 'Carbon Races | Finger Lakes Climate Fund', description: 'Compete with other teams around the Finger Lakes to see who offsets the most carbon', keywords: 'carbon, offsets, race, game, competition'
    @teams = Team.all
    @prizes = Prize.where('count > 0')
    count = 0
    @prizes.each do |p|
      count += p.count
    end
    @empties = count * 3
  end

  def js_test; end

  def offset_log
    @offsets = Offset.where(purchased: :true).order(created_at: :desc)
    render 'offset_log', layout: 'blank'
  end

  def calculator
    render 'calculator', layout: 'iframe'
  end

  def page_params
    params.require(:page).permit(:body, :title)
  end

  def verification
    render plain: '870E0E2346D565F9BE3056DD58219B8914AF9F9A994D08FDD3612C9FB227BC96 comodoca.com 5efc06b064907'
  end
end
