class Region < ActiveRecord::Base
    has_many :offsets
    has_many :prizes
    has_many :teams
    has_many :individuals
    has_many :awardees
    
end
