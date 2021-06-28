class AddRecurringOptionsToCartItems < ActiveRecord::Migration[5.2]
  def change
    add_column :cart_items, :frequency, :string
  end
end
