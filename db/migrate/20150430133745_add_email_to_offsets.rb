class AddEmailToOffsets < ActiveRecord::Migration
  def change
    add_column :offsets, :email, :string
  end
end
