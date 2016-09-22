class PrizesController < ApplicationController

  def save
    puts params[:prize]
    puts params[:email]
    rec = PrizeWinner.where(:prize_id=>params[:prize], :email=>nil).first
    rec.update_attribute(:email, params[:email])
  end

end