class PrizeWinnersController < ApplicationController

  def destroy
    pw = PrizeWinner.find(params[:id])
    pw.prize.increment!(:count)
    pw.destroy
    @id = params[:id]
  end

end
