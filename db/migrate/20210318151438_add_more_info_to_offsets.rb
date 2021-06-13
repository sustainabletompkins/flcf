class AddMoreInfoToOffsets < ActiveRecord::Migration[5.2]
  def change
    add_column :offsets, :offset_type, :string
    add_column :offsets, :offset_interval, :string
  end
end
