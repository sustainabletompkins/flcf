class Team < ActiveRecord::Base

  has_many :offsets
  has_many :users

end
