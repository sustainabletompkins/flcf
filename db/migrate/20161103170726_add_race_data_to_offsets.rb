class AddRaceDataToOffsets < ActiveRecord::Migration[5.1]
  def change
    add_column :offsets, :team_id, :integer, :default=>0
    add_column :offsets, :individual_id, :integer, :default=>0
  end
end
