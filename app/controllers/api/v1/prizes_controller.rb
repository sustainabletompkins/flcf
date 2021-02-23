class Api::V1::PrizesController < ApplicationController

    before_action :authenticate_api_user
  
    def authenticate_api_user
        @api_user = User.where(:id=>params[:api_key], :api_secret=>params[:api_secret]).first
        if @api_user.present?
        else
            head(401)
        end
    end

    def winners
        # TO DO: filter by time range and region
        winners = PrizeWinner.where.not(:email=>nil).order(created_at: :desc)
        if params.has_key?(:start_date)
            winners = winners.where('created_at > ?', params[:start_date])
        end
        if params.has_key?(:end_date)
            winners = winners.where('created_at < ?', params[:end_date])
        end
        serializable_response = ActiveModelSerializers::SerializableResource.new(winners, each_serializer: PrizeWinnerSerializer).to_json
        render json: serializable_response
    end

    def list
        # TO DO: filter by region
        prizes = Prize.all.order(count: :asc)
        render json: prizes
    end


end