class CreateCartItems < ActiveRecord::Migration[5.2]
  def change
    create_table :cart_items do |t|
      t.string :title
      t.float :cost
      t.float :pounds
      t.references :user, foreign_key: true
      t.integer :session_id
      t.string :checkout_session_id
      t.string :price_id
      t.string :schedule
      t.boolean :purchased, :default => false
      t.timestamps
    end
  end
end
