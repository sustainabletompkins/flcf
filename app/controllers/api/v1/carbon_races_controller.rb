class Api::V1::CarbonRacesController < ApplicationController
  before_action :authenticate_api_user

  def authenticate_api_user
    @api_user = User.where(id: params[:api_key], api_secret: params[:api_secret]).first
    if @api_user.present?
    else
      head(401)
    end
  end

  def leaderboard
    leaders = Team.generate_leaderboard(params[:start_date], params[:end_date], params[:region], params[:limit].to_i, params[:offset].to_i, params[:leaderboard])
    render json: leaders
  end

  def team
    # TO DO: order by pounds
    team_list = TeamMember.where(team: params[:team]).order(offsets: :desc)
    render json: team_list
  end
end
