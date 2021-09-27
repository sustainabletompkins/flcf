class Team < ActiveRecord::Base
  has_many :offsets
  has_many :team_members
  belongs_to :region
  validates :name, uniqueness: true
  has_one_attached :image

  include Rails.application.routes.url_helpers

  def self.generate_leaderboard(start_date = nil, end_date = nil, region = nil, limit = 0, offset = 0, solo_mode = nil)
    results = []
    puts region
    region = Region.where(name: region).first
    puts region.inspect
    start_date = if start_date.nil?
                   Time.now - 20.years
                 else
                   start_date.to_datetime
                 end
    end_date = if end_date.nil?
                 Time.now
               else
                 end_date.to_datetime
               end

    if solo_mode
      Individual.all.each do |team|
        offsets = team.offsets.where('created_at > ? and created_at < ?', start_date, end_date)
        offsets = offsets.where(region: region) if region.present?
        results << { team: team.name, pounds: offsets.sum(&:pounds), count: offsets.count }
      end
    else
      Team.all.each do |team|
        offsets = if end_date - start_date > 1.day
                    team.offsets.where('created_at > ? and created_at < ?', start_date, end_date)
                  else
                    team.offsets
                  end
        offsets = offsets.where(region: region) if region.present?
        if offsets.count > 0
          results << { team: team.name, pounds: offsets.sum(&:pounds), count: offsets.count, region: team.region.name, image: team.image.attached? ? Rails.application.routes.url_helpers.url_for(team.image) : '' }

        end
      end
    end
    results = results.sort_by { |k| k[:pounds] }.reverse
    results = results[offset..(offset + limit - 1)] if limit > 0
    results
  end

  def cover_url
    rails_blob_path(image, disposition: 'attachment', host: 'http://localhost:3000')
  end
end
