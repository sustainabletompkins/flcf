class AddDefaultToTeams < ActiveRecord::Migration
  def change
    change_column_default(:teams, :pounds, 0)
  end
end
