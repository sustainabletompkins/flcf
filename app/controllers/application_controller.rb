class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_action :check_for_offsets
  before_action :configure_permitted_parameters, if: :devise_controller?


  protected


  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation,:name, :zipcode, :session_id) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password, :name, :zipcode, :session_id) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :name, :zipcode, :password, :password_confirmation, :current_password) }
  end

  def check_for_offsets
    @offsets = Offset.all
    set_meta_tags title: 'Finger Lakes Climate Fund - Local Carbon Offsets', description: 'Your carbon offsets help fund home efficiency upgrades around Tompkins County',keywords: 'carbon, offsets, calculator, climate, change, grants, award, fund, program'
  end



end
