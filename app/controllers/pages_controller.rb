class PagesController < ApplicationController

  http_basic_authenticate_with :name => "admin", :password => "309NAurora", :only => [:admin, :list, :offset_log]

  def home
    if params.has_key?('checkout_session_id')
      # create the offset objects
      @checkout_session = params["checkout_session_id"]
      zipcode = nil
      name = nil
      email = nil
      session = Stripe::Checkout::Session.retrieve(@checkout_session)
      puts session.inspect
      if session.payment_intent
        paymentIntent = Stripe::PaymentIntent.retrieve(
          session.payment_intent
        )
        
        paymentMethod = Stripe::PaymentMethod.retrieve(
          paymentIntent.payment_method,
        )
        zipcode = paymentMethod["billing_details"]["address"]["postal_code"]
        name = paymentMethod["billing_details"]["name"]
        email = paymentMethod["billing_details"]["email"]
        puts paymentMethod.inspect
        puts paymentIntent.inspect
      else
        cards = Stripe::Customer.list_sources(
          session.customer,
          {object: 'card', limit: 3}
        )
        customer = Stripe::Customer.retrieve(session.customer)
        puts customer.inspect
        puts 'hey hey key'
        puts cards.inspect
        # TO DO: get zip and name
      end

      @offsets = []
      CartItem.where(:checkout_session_id=> @checkout_session).each do |item|
        @offsets << Offset.create(:name => name, :user_id=>item.user_id,:title=>item.title,:cost=>item.cost,:pounds=>item.pounds,:offset_type=>item.offset_type,:offset_interval=>item.offset_interval, :zipcode => zipcode, :checkout_session_id => @checkout_session, :email=>email)
        item.update_attribute(:purchased, true)
      end

      has_prize_choices = true
      region = Region.get_by_zip(zipcode)
      has_prize_choices = region && region.prizes.where('count > 0').first.present?
      #has_prize_choices = false
      if has_prize_choices
        set_meta_tags title: 'Carbon Offset Prize Wheel | Finger Lakes Climate Fund', description: 'Thanks for your carbon offset!  Now, try your luck on the wheel to win prizes from local businesses',keywords: 'carbon, offsets, race, game, competition'
        @teams = Team.all
        
        @prizes = region.prizes.where('count > 0')
        count = 0
        @prizes.each do |p|
          count = count+p.count
        end
        @empties = count*4
        @app_mode = "prize wheel"
      else
        @app_mode = "carbon races"
        # does this email address already belong to a team
        team_member = TeamMember.where(:email => @offsets.first.email).order('updated_at DESC').first
        if team_member.present?
          @team = team_member.team
        end
        puts @team.inspect
        @teams = Team.all
      end
    else
      @app_mode = "calculator"
    end
    puts @app_mode
    render 'spa/app'
    
  end

  def index
    @page = Page.where(:slug=>params[:page_name]).first
    if @page.present?
      render 'index'
    else
      if params[:page_name] == 'prize-wheel'
        set_meta_tags title: 'Carbon Offset Prize Wheel | Finger Lakes Climate Fund', description: 'Thanks for your carbon offset!  Now, try your luck on the wheel to win prizes from local businesses',keywords: 'carbon, offsets, race, game, competition'
        @teams = Team.all
        @prizes = Prize.where('count > 0')
        count = 0
        @prizes.each do |p|
          count = count+p.count
        end
        @empties = count*4
        render params[:page_name], :layout => "full"
      elsif params[:page_name] == 'carbon-races'
        set_meta_tags title: 'Carbon Races | Finger Lakes Climate Fund', description: 'Compete with other teams around the Finger Lakes to see who offsets the most carbon',keywords: 'carbon, offsets, race, game, competition'

        @teams = Team.all
        @leaders = Team.where('pounds > 0').order(pounds: :desc)
        @individual_leaders = Individual.where('pounds > 0').where.not(:name=>"Anonymous").order(pounds: :desc)
        render params[:page_name], :layout => "full"
      else
        render params[:page_name]
      end
    end

  end

  def card_error
    
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
    @page.slug = params[:page][:title].downcase.gsub(' ','-')
    if @page.save
      @url = "http://fingerlakesclimatefund.org/pages/"+@page.slug
      render 'created'
    else
      render 'error'
    end
  end
  def index2



  end

  def admin
    @prizes = PrizeWinner.where.not(:email=>nil).order(created_at: :asc).last(15).reverse
    @prize_list = Prize.where(:region_id=>1)
    @offsetters = Offsetter.all
    @teams = Team.all
    @awardees = Awardee.all
    @individuals = Individual.all.order(pounds: :desc)
    @message_templates = MessageTemplate.all
    @teams = Team.all.order(pounds: :desc)
    @stat = Stat.find(1)
    render :layout=>"full"
  end

  def prize_wheel
    set_meta_tags title: 'Carbon Races | Finger Lakes Climate Fund', description: 'Compete with other teams around the Finger Lakes to see who offsets the most carbon',keywords: 'carbon, offsets, race, game, competition'
    @teams = Team.all
    @prizes = Prize.where('count > 0')
    count = 0
    @prizes.each do |p|
      count = count+p.count
    end
    @empties = count*3
  end

  def offset_log
    @offsets = Offset.where(:purchased => :true).order(created_at: :desc)
    render 'offset_log', :layout => 'blank'
  end

  def calculator
    render 'calculator', :layout => "iframe"
  end

  def page_params
    params.require(:page).permit(:body, :title)
  end

  def verification
    render :plain => '870E0E2346D565F9BE3056DD58219B8914AF9F9A994D08FDD3612C9FB227BC96 comodoca.com 5efc06b064907'
  end
end
