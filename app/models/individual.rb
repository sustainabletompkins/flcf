class Individual < ActiveRecord::Base

  belongs_to :region
  has_many :offsets
  validates :name, uniqueness: true
end
