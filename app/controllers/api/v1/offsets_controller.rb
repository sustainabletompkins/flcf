class Api::V1::OffsetsController < ApplicationController

    before_action :authenticate_api_user
  
    def authenticate_api_user
        @api_user = User.where(:id=>params[:api_key], :api_secret=>params[:api_secret]).first
        if @api_user.present?
        else
            head(401)
        end
    end

    def air
        render json: Offset.from_air_travel(params[:flights], params[:travelers])
    end

    def car
        render json: Offset.from_car_travel(params[:miles], params[:mpg])
    end

    def home_energy
        render json: Offset.from_home_energy(params[:propane], params[:natural_gas], params[:fuel_oil], params[:electricity])
    end

    def quick
        render json: Offset.from_quick_entry(params[:offset_mode], params[:months])
    end

end