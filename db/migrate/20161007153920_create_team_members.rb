class CreateTeamMembers < ActiveRecord::Migration[5.1]
  def change
    create_table :team_members do |t|
      t.string :email
      t.string :name
      t.integer :offsets
      t.integer :team_id
      t.boolean :founder
      t.integer :user_id
      t.timestamps

    end
  end
end
