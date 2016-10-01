class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.integer :pounds
      t.float :dollars
      t.integer :offsets
      t.integer :awardees
    end
  end
end
