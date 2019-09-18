class AddWheelSpinsToStats < ActiveRecord::Migration[5.1]
  def change
    add_column :stats, :wheel_spins, :integer, :default=>0
  end
end
