class Awardee < ActiveRecord::Base

  belongs_to :region
  
  has_attached_file :avatar, styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '400x400>'
  }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def self.to_csv
    require 'csv'
    CSV.open("awardees.csv", "w") do |csv|
      column_names = %w(Name Description Image Video Amount Pounds)
      csv << column_names
      all.each do |awardee|
        csv << [awardee.name, awardee.bio, awardee.avatar_file_name, awardee.video_id, awardee.award_amount, awardee.pounds_offset]
      end
    end
  end

end
