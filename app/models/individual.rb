class Individual < ActiveRecord::Base

  validates :name, uniqueness: true
end
