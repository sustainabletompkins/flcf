class ChargesController < ApplicationController

  def new
  end

  def create

    if user_signed_in?
      current_user.session_id = nil
      current_user.save
    end

    Offset.where(:session_id=>params[:stripeSession]).each do |o|
      o.purchased = true
      o.email = params[:stripeEmail]
      o.save
    end

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
    render :layout=>"full"

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end


end
