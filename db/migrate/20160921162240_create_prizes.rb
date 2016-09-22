class CreatePrizes < ActiveRecord::Migration
  def change
    create_table :prizes do |t|
      t.string :title
      t.string :description
      t.integer :count
      t.datetime :expiration_date
    end
  end
end
