class CreateOffsets < ActiveRecord::Migration[5.1]
  def change
    create_table :offsets do |t|
      t.belongs_to :user
      t.string :title
      t.float :pounds
      t.float :cost
      t.string :units
      t.float :quantity
      t.boolean :purchased, :default => :false
    end
  end
end
