class PrizesController < ApplicationController

  def save
    rec = PrizeWinner.where(:prize_id=>params[:prize], :email=>nil).first
    rec.update_attribute(:email, params[:email])

    rec.update_attribute(:name, params[:name]) if params[:name].length > 0
    PrizeMailer.send_prize_details(params[:email],rec.code,rec.prize.title,"this is a test")
  end

end