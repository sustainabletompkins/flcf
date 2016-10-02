class TeamsController < ApplicationController

  def create
    @league = Team.create(team_params)
    @league.update_attribute(:count, 1)
    render 'team_created_after_offset'
  end

  def join
    @team = Team.find(params[:league_id])
    @pounds = params[:pounds]
    @team.increment!(:count, 1)
    @team.increment!(:pounds, params[:pounds].to_i)
    render 'team_joined_after_offset'
  end

  private
  def team_params
    params.require(:team).permit(:name, :members, :pounds)
  end

end