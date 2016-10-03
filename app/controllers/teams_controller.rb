class TeamsController < ApplicationController

  def create
    @league = Team.create(team_params)
    if params.has_key?(:pounds)
      @league.update_attribute(:count, 1)
      @league.increment!(:pounds, params[:pounds].to_i)
      render 'team_created_after_offset'
    else
      @count = Team.all.count
      render 'team_created'
    end
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