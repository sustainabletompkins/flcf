class AddDefaultToTeams < ActiveRecord::Migration[5.1]
  def change
    change_column_default(:teams, :pounds, 0)
  end
end
