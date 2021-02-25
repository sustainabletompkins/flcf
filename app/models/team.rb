class Team < ActiveRecord::Base

  has_many :offsets
  has_many :team_members
  belongs_to :region
  validates :name, uniqueness: true
end
