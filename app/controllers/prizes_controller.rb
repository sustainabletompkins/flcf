class PrizesController < ApplicationController

  def save
    rec = PrizeWinner.where(:prize_id=>params[:prize], :email=>nil).first
    rec.update_attribute(:email, params[:email])
    prize = rec.prize
    prize.decrement!(:count)

    rec.update_attribute(:name, params[:name]) if params[:name].length > 0
    #PrizeMailer.send_prize_details(params[:email],rec.code,rec.prize.title,"this is a test")
  end

  def create
    Prize.create(prize_params)
    redirect_to '/admin'
  end

  def update
    @user = Prize.find params[:id]

    respond_to do |format|
      if @user.update_attributes(prize_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  private
  def prize_params
    params.require(:prize).permit(:title, :description, :count, :avatar,:expiration_date)
  end
end