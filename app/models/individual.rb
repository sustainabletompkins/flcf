class Individual < ActiveRecord::Base

  belongs_to :region
  validates :name, uniqueness: true
end
