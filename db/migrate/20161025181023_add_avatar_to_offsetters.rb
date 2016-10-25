class AddAvatarToOffsetters < ActiveRecord::Migration
  def self.up
    add_attachment :offsetters, :avatar
  end

  def self.down
    remove_attachment :offsetters, :avatar
  end
end
