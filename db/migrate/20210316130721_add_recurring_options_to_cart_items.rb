class AddRecurringOptionsToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :offset_type, :string
    add_column :cart_items, :frequency, :string
    add_column :cart_items, :offset_interval, :string
  end
end
