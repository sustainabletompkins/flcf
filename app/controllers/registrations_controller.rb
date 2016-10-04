class RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_filter :verify_authenticity_token, :only => :create
  def create
    super

    resource.session_id = sign_up_params[:session_id]
    resource.save

    if params[:user][:join_team] == "true"
      pounds=0
      @user_offsets = Offset.where(:session_id => resource.session_id)
      @user_offsets.each do |o|
        o.user_id = resource.id
        o.name = params[:user][:name]
        o.zipcode = params[:user][:zipcode]
        o.save
        pounds = pounds = o.pounds
      end
      Individual.create(:name=>resource.name, :pounds=>pounds, :count=>1)
      cookies[:joined] = "true"

    end


  end

end
