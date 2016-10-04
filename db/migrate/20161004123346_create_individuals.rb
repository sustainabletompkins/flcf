class CreateIndividuals < ActiveRecord::Migration
  def change
    create_table :individuals do |t|
      t.string :name
      t.integer :pounds
      t.integer :count
    end
  end
end
