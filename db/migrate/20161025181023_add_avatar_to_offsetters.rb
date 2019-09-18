class AddAvatarToOffsetters < ActiveRecord::Migration[5.1]
  def self.up
    add_attachment :offsetters, :avatar
  end

  def self.down
    remove_attachment :offsetters, :avatar
  end
end
