class Team < ActiveRecord::Base

  has_many :offsets
  has_many :team_members
  belongs_to :region
  validates :name, uniqueness: true

  def self.generate_leaderboard(start_date = nil, end_date = nil, region=nil, solo_mode=nil)
    results = []
    if start_date.nil?
      start_date = Time.now - 20.years
    end
    if end_date.nil?
      end_date = Time.now
    end

    if solo_mode
      Individual.all.each do |team|
        offsets = team.offsets.where('created_at > ? and created_at < ?',start_date, end_date)
        if region.present?
          offsets = offsets.where(:region=>Region.where(:name=>region).first)
        end
        results << {team: team.name, pounds: offsets.sum(&:pounds), count: offsets.count}
      end
    else
      Team.all.each do |team|
        if end_date-start_date > 1.day
          offsets = team.offsets.where('created_at > ? and created_at < ?',start_date, end_date)
        else
          offsets = team.offsets
        end
        if region.present?
          offsets = offsets.where(:region=>Region.where(:name=>region).first)
        end
        results << {team: team.name, pounds: offsets.sum(&:pounds), count: offsets.count}
      end
    end
    puts region.inspect
    return results
  end
end
