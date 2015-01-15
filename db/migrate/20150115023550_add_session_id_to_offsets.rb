class AddSessionIdToOffsets < ActiveRecord::Migration
  def change
    add_column :offsets, :session_id, :string
  end
end
