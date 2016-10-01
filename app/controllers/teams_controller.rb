class TeamsController < ApplicationController

  def create
    @league = Team.create(team_params)
    render 'team_created_after_offset'
  end

  private
  def team_params
    params.require(:team).permit(:name, :members)
  end

end