class Prize < ActiveRecord::Base
  belongs_to :region

  has_many :prize_winners, dependent: :destroy
  has_one_attached :image
end
