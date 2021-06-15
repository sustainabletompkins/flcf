class PrizeWinnersController < ApplicationController

  def create
    checkout_session_id = params["checkout_session_id"]
    offsets = Offset.where(:checkout_session_id => checkout_session_id)
    rec = PrizeWinner.create(:prize_id=>params[:prize], :email=>offsets.first.email, :name=> offsets.first.name.split(' ').first)
    prize = rec.prize
    prize.decrement!(:count)
    #PrizeMailer.send_prize_details(params[:email],rec.code,rec.prize.title,"this is a test")
  end

  def destroy
    pw = PrizeWinner.find(params[:id])
    pw.prize.increment!(:count)
    pw.destroy
    @id = params[:id]
  end

end
