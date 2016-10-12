class ChargesController < ApplicationController

  def new
  end

  def create

    if user_signed_in?
      current_user.session_id = nil
      current_user.save
    end
    @stat = Stat.all.first
    @offset_data = {:pounds=>0, :cost=>0}
    @player = TeamMember.where(:email=>params[:stripeEmail]).first
    if @player
      @team = Team.find(@player.team_id)
      @player.increment!(:offsets)
    end
    @individual = Individual.where(:email=>params[:stripeEmail]).first

    Offset.where(:session_id=>params[:stripeSession]).where('purchased = FALSE').each do |o|
      o.purchased = true
      o.email = params[:stripeEmail]
      o.save
      @offset_data[:pounds] = @offset_data[:pounds] + o.pounds
      @offset_data[:cost] = @offset_data[:cost] + o.cost
      @offset_data[:email] = params[:stripeEmail]
      @stat.increment!(:pounds, o.pounds)
      @stat.increment!(:dollars, o.cost)
    end
    if @individual
      @individual.increment!(:count)
      @individual.increment!(:pounds,@offset_data[:pounds].to_i)
    end
    @teams = Team.all
    @prizes = Prize.where('count > 0')
    count = 0
    @prizes.each do |p|
      count = count+p.count
    end
    @empties = count*3

    customer = Stripe::Customer.create(
      :email => params[:stripeEmail],
      :card  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => params[:stripeCharge],
      :description => 'Carbon offset',
      :currency    => 'usd'
    )
    @recent_offsets = Offset.where(:purchased=>:true).order(id: :desc).limit(5)
    @teams = Team.all
    render :layout=>"full"


  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end


end
