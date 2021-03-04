class CartItem < ActiveRecord::Base

  belongs_to :user, optional: true
  validates_numericality_of :cost, :pounds

end