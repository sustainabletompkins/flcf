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
        render json: winners.to_json(include: :prize)
    end

    def list
        # TO DO: filter by region
        prizes = Prize.all.order(count: :asc)
        render json: prizes
    end


end