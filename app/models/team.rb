class Team < ActiveRecord::Base

  has_many :offsets
  has_many :team_members

end
