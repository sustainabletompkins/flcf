class PagesController < ApplicationController
  http_basic_authenticate_with name: 'admin', password: '309NAurora', only: %i[admin list offset_log]

  def payment_success
    if params.has_key?('checkout_session_id')
      begin
        @checkout_session = params['checkout_session_id']
        session = Stripe::Checkout::Session.retrieve(@checkout_session)
        zipcode, name, email = nil, nil, nil

        if session.payment_intent
          payment_intent = Stripe::PaymentIntent.retrieve(session.payment_intent)
          payment_method = Stripe::PaymentMethod.retrieve(payment_intent.payment_method)
          zipcode = payment_method['billing_details']['address']['postal_code']
          name = payment_method['billing_details']['name']
          email = payment_method['billing_details']['email']
        else
          cards = Stripe::Customer.list_sources(session.customer, { object: 'card', limit: 3 })
          customer = Stripe::Customer.retrieve(session.customer)
          # TO DO: get zip and name
        end

        # Validate and set default values for zipcode and name
        zipcode = '14850' unless valid_zipcode?(zipcode)
        name = "{name unknown}" if name.blank?
        region = Region.get_by_zip(zipcode)
        total_cost = 0.0

        # Convert cart items into completed offsets and calculate total cost
        CartItem.where(checkout_session_id: @checkout_session).find_each do |item|
          Offset.create!(
            name: name,
            user_id: nil,
            title: item.title,
            cost: item.cost,
            pounds: item.pounds,
            offset_type: item.offset_type,
            offset_interval: item.offset_interval,
            zipcode: zipcode,
            region: region,
            checkout_session_id: @checkout_session,
            email: email,
            purchased: true
          )
          item.update!(purchased: true)
          total_cost += item.cost.to_f
        end

        # Post to LGL via background job
        LglJob.perform_async(email, total_cost, name, zipcode)

        # Redirect to the appropriate page
        redirect_to "https://fingerlakesclimatefund.org/?c_id=#{@checkout_session}"
      rescue Stripe::StripeError => e
        Rails.logger.error("Stripe error: #{e.message}")
        redirect_to error_path, alert: 'Payment processing error. Please try again.'
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error("Database error: #{e.message}")
        redirect_to error_path, alert: 'Database error. Please try again.'
      rescue StandardError => e
        Rails.logger.error("Unknown error: #{e.message}")
        redirect_to error_path, alert: 'An unexpected error occurred. Please try again.'
      end
    else
      # Handle missing checkout session ID
      @app_mode = 'error'
      render 'spa/app'
    end
  end

  def valid_zipcode?(zipcode)
    # Regular expression for a valid U.S. ZIP code
    zipcode_regex = /\A\d{5}(-\d{4})?\z/

    # Check if the input string matches the regular expression
    !!(zipcode =~ zipcode_regex)
  end

  def index
    # response.headers['X-FRAME-OPTIONS'] = 'ALLOW-FROM http://gayn.sg-host.com/, https://hyadev.com/'
    if params.has_key?('checkout_session_id')
      # user has just completed a checkout
      # handle carbon races and prize wheel\
      @checkout_session = params['checkout_session_id']
      # start by getting offsets associated with checkout session
      @offsets = Offset.where(checkout_session_id: @checkout_session)
      # error is here
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
        # sync the offset count in TeamMember to the correct amount
        team_member.count_offsets
      elsif player.present?
        puts player.inspect
        @offsets.update_all(individual_id: player.id)
        player.count_offsets
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

  def processing_error
    render 'processing_error'
  end

  def verification
    if params[:filename] == '967C9E3CE0C86DA5CFBBFB204A4EF995.txt'
      render plan: 'CCEAC6616A4863B51F9280201E4F43598116262854B02C61EC739023A4DEDC53 comodoca.com 61801d26d14d8'
    else
      render plain: '3D053997760490550BD9B5E198F4880F3207D6F69F1B778DCD3E987576DF2E46 comodoca.com 6334e37295071'
    end
  end

  private

  def error_path
    "/processing-error"
  end
end
