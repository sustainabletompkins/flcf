class SessionsController < Devise::SessionsController
  def create
    super
    puts "asdsfff"
    resource.session_id = sign_in_params[:session_id]
    resource.save
    @user_offsets = Offset.where(:session_id => resource.session_id)
    @user_offsets.each do |o|
      o.user_id = resource.id
      o.name = current_user.name
      o.zipcode = current_user.zipcode
      o.save
    end
  end

  def new
    super
  end

  def destroy
    super
  end
end