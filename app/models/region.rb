class Region < ActiveRecord::Base
    has_many :offsets
    has_many :prizes
    has_many :teams
    has_many :individuals
    has_many :awardees
    
    def self.get_by_zip(zip)
        region = nil
        Region.all.each do |r|
            puts r.zipcodes
            if r.zipcodes.include? zip.to_s
                region = r
            end
        end
        return region
    end
end
