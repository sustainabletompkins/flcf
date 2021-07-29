class IndividualsController < ApplicationController


  def create
    offsets = Offset.where(:checkout_session_id => params[:checkout_session_id])
    @i = Individual.where(:email=>offsets.first.email).first
    if @i.present?
      
    else
      region = Region.get_by_zip(offsets.first.zipcode)
      @i=Individual.create(:name=>params[:individual][:name], :email => offsets.first.email, :region=>region)
    end
    offsets.update_all(:individual_id => @i.id)
    # redirect to standings
  end
  
  def update
    @user = Individual.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(individual_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end
  private
  def individual_params
    params.require(:individual).permit(:name, :pounds)
  end

end