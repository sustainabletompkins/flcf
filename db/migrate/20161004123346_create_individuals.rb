class CreateIndividuals < ActiveRecord::Migration[5.1]
  def change
    create_table :individuals do |t|
      t.string :name
      t.integer :pounds
      t.integer :count
    end
  end
end
