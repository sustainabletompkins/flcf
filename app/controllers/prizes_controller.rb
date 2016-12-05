class PrizesController < ApplicationController

  def save
    rec = PrizeWinner.create(:prize_id=>params[:prize], :email=>params[:email], :name=> params[:name])
    prize = rec.prize
    prize.decrement!(:count)
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
  def destroy
    Prize.find(params[:id]).destroy
    @id = params[:id]
  end

  def log
    s = Stat.find(1)
    s.increment!(:wheel_spins)
  end


  private
  def prize_params
    params.require(:prize).permit(:title, :description, :count, :avatar,:expiration_date)
  end
end