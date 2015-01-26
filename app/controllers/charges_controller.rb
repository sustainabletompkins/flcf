class ChargesController < ApplicationController

  def new
  end

  def create

    @amount = (current_user.offsets.where(:purchased=>:false).sum(:cost) * 100).to_i
    puts @amount
    current_user.session_id = nil
    current_user.save
    current_user.offsets.each do |o|
      o.purchased = true
      o.save
    end
    customer = Stripe::Customer.create(
      :email => 'example@stripe.com',
      :card  => params[:stripeToken]
    )

    charge = Stripe::Charge.create(
      :customer    => customer.id,
      :amount      => @amount,
      :description => 'Rails Stripe customer',
      :currency    => 'usd'
    )

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to charges_path
  end


end
