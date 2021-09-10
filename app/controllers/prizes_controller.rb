class PrizesController < ApplicationController
  def create
    if simple_captcha_valid?
      Prize.create(prize_params)
      redirect_to '/calc-admin'
    else
      render 'shared/captcha_failed'
    end
  end

  def update
    @user = Prize.find params[:id]

    respond_to do |format|
      if @user.update_attributes(prize_params)
        format.html { redirect_to(@user, notice: 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render action: 'edit' }
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

  def index
    @prizes = if params.has_key?(:region)
                Prize.where(region_id: params[:region])
              else
                Prize.all
              end
    render 'list'
  end

  private

  def prize_params
    params.require(:prize).permit(:title, :description, :count, :region_id, :image, :expiration_date, :captcha, :captcha_key)
  end
end
