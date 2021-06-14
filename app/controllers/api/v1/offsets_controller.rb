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

    def summary
        @offsets = Offset.all
        if params.has_key?(:start_date)
            @offsets = @offsets.where('created_at > ?', params[:start_date])
        end
        if params.has_key?(:end_date)
            @offsets = @offsets.where('created_at < ?', params[:end_date])
        end
        if params.has_key?(:region)
            @offsets = @offsets.where(:region => Region.where(:name=>params[:region]).first)
        end
        render json: {pounds: @offsets.sum(:pounds).round(0), co2: (@offsets.sum(:pounds)/20).round(0), dollars: @offsets.sum(:cost).round(2)}
    end

    def list 
        @offsets = Offset.where(:purchased => :true)
        if params.has_key?(:start_date)
            @offsets = @offsets.where('created_at > ?', params[:start_date])
        end
        if params.has_key?(:end_date)
            @offsets = @offsets.where('created_at < ?', params[:end_date])
        end
        @offsets = @offsets.order(created_at: :desc)
        serializable_response = ActiveModelSerializers::SerializableResource.new(@offsets, each_serializer: OffsetSerializer).to_json
        render json: serializable_response
    end

end