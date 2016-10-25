class AddAvatarToPrizes < ActiveRecord::Migration
  def self.up
    add_attachment :prizes, :avatar
  end

  def self.down
    remove_attachment :prizes, :avatar
  end
end
