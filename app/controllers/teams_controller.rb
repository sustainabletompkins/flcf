class TeamsController < ApplicationController

  def create
    @league = Team.create(team_params)
    if team_params.has_key?(:pounds)
      @league.update_attribute(:count, 1)
      @league.update_attribute(:members, 1)
      @league.increment!(:pounds, params[:pounds].to_i)
      render 'team_created_after_offset'
    else
      @count = Team.all.count
      render 'team_created'
    end
    TeamMember.create(:email => params[:user_email], :name=> params[:member_name], :offsets => 1, :founder=> "TRUE", :team_id=>@league.id)
  end

  def join
    @team = Team.find(params[:league_id])
    @pounds = params[:pounds]
    @team.increment!(:count, 1)
    @team.increment!(:members, 1)
    @team.increment!(:pounds, params[:pounds].to_i)
    TeamMember.create(:email => params[:user_email], :offsets => 1, :team_id=>@team.id, :name=> params[:name])
    render 'team_joined_after_offset'

  end

  def show
    @team = Team.find(params[:id])
    @leaders = Team.all.order(pounds: :desc)
  end

  private
  def team_params
    params.require(:team).permit(:name, :pounds)
  end

end