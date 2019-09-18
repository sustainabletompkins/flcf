class AddAvatarToPrizes < ActiveRecord::Migration[5.1]
  def self.up
    add_attachment :prizes, :avatar
  end

  def self.down
    remove_attachment :prizes, :avatar
  end
end
