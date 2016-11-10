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

  private
  def team_params
    params.require(:team).permit(:name, :pounds)
  end

end