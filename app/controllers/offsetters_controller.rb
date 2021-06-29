class OffsettersController < ApplicationController


  def create
    if simple_captcha_valid?
      Offsetter.create(offsetter_params)
      redirect_to '/admin'
    else
      render 'shared/captcha_failed'
    end
  end
  def update
    @user = Offsetter.find params[:id]

    respond_to do |format|
      if @user.update_attributes(offsetter_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  def destroy
    Offsetter.find(params[:id]).destroy
    @id = params[:id]
  end

  def csv
    headers = %w(Name Description Image)

    csv_data = CSV.generate(headers: true) do |csv|
      csv << headers
      Offsetter.all.order(id: :asc).each do |item|
        csv << [item.name, item.description, item.avatar_file_name]
      end
    end
    send_data csv_data, filename: "offsetters.csv", disposition: :attachment
  end

  private
  def offsetter_params
    params.require(:offsetter).permit(:name, :description,:avatar,:captcha, :captcha_key)
  end
end