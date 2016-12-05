class AddWheelSpinsToStats < ActiveRecord::Migration
  def change
    add_column :stats, :wheel_spins, :integer, :default=>0
  end
end
