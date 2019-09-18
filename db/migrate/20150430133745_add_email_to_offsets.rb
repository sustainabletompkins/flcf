class AddEmailToOffsets < ActiveRecord::Migration[5.1]
  def change
    add_column :offsets, :email, :string
  end
end
