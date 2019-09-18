class AddSessionIdToOffsets < ActiveRecord::Migration[5.1]
  def change
    add_column :offsets, :session_id, :string
  end
end
