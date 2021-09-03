class Team < ActiveRecord::Base
  has_many :offsets
  has_many :team_members
  belongs_to :region
  validates :name, uniqueness: true

  def self.generate_leaderboard(start_date = nil, end_date = nil, region = nil, solo_mode = nil)
    results = []
    start_date = Time.now - 20.years if start_date.nil?
    end_date = Time.now if end_date.nil?

    if solo_mode
      Individual.all.each do |team|
        offsets = team.offsets.where('created_at > ? and created_at < ?', start_date, end_date)
        offsets = offsets.where(region: Region.where(name: region).first) if region.present?
        results << { team: team.name, pounds: offsets.sum(&:pounds), count: offsets.count }
      end
    else
      Team.all.each do |team|
        offsets = if end_date - start_date > 1.day
                    team.offsets.where('created_at > ? and created_at < ?', start_date, end_date)
                  else
                    team.offsets
                  end
        offsets = offsets.where(region: Region.where(name: region).first) if region.present?
        results << { team: team.name, pounds: offsets.sum(&:pounds), count: offsets.count, region: team.region.name }
      end
    end
    puts region.inspect
    results
  end
end
