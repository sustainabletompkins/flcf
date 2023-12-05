class UpdateOffsets < ActiveRecord::Migration[5.2]
  def change
    remove_column :offsets, :units
    remove_column :offsets, :quantity
    remove_column :offsets, :session_id
    add_column :offsets, :checkout_session_id, :string
  end
end
