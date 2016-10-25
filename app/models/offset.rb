class Offset < ActiveRecord::Base

  belongs_to :user
  validates_numericality_of :cost, :pounds

end
