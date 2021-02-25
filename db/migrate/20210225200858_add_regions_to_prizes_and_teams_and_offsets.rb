class AddRegionsToPrizesAndTeamsAndOffsets < ActiveRecord::Migration[5.2]
  def change
    add_reference :offsets, :region, foreign_key: true
    add_reference :prizes, :region, foreign_key: true
    add_reference :teams, :region, foreign_key: true
    add_reference :individuals, :region, foreign_key: true
    add_reference :awardees, :region, foreign_key: true
  end
end
