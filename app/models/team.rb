class Team < ActiveRecord::Base

  has_many :offsets
  has_many :team_members
  validates :name, uniqueness: true
end
