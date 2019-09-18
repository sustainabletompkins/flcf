class AddAvatarToAwardees < ActiveRecord::Migration[5.1]
  def self.up
    add_attachment :awardees, :avatar
  end

  def self.down
    remove_attachment :awardees, :avatar
  end
end
