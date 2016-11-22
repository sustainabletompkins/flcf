class IndividualsController < ApplicationController


  def add_to
    @email = params[:individual][:email]
    @id = params[:individual][:offset_id]
    @offset = Offset.find(@id)
    @i = Individual.where(:email=>@email).first
    if @i.present?
      @i.update_attributes(:count=>@i.count+1,:pounds=>@i.pounds+params[:individual][:pounds].to_i)
      @offset.update_attribute(:individual_id, @i.id)
    else
      @i=Individual.create(:name=>params[:individual][:name], :pounds=>params[:individual][:pounds], :count=>1, :email => @email)
      @offset.update_attribute(:individual_id, @i.id)
    end
  end
  def update
    @user = Individual.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(team_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end
  private
  def team_params
    params.require(:individual).permit(:name, :pounds)
  end

end