class Api::V1::CarbonRacesController < ApplicationController

    before_action :authenticate_api_user
  
    def authenticate_api_user
        @api_user = User.where(:id=>params[:api_key], :api_secret=>params[:api_secret]).first
        if @api_user.present?
        else
            head(401)
        end
    end

    def leaderboard
        if params[:list] == 'individuals'
            # insert filters here: date range, region
            leaders = Individual.where('pounds > 0').where.not(:name=>"Anonymous").order(pounds: :desc)
        else
            leaders = Team.where('pounds > 0')
        end
        if params.has_key?(:order) && params[:order] == 'offset_count'
            leaders = leaders.order(count: :desc)
        else
            leaders = leaders.order(pounds: :desc)
        end
        render json: leaders
    end

    def team
        # TO DO: order by pounds
        team_list = TeamMember.where(:team => params[:team]).order(offsets: :desc)
        render json: team_list
    end


end