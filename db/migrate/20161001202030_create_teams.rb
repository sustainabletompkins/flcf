class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :members
      t.integer :pounds
      t.integer :count
      t.float :participation_rate
    end
  end
end
