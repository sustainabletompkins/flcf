class Offsetter < ActiveRecord::Base


  has_attached_file :avatar, styles: {
    thumb: '100x100>',
    square: '200x200#',
    medium: '300x300>'
  }

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def self.to_csv
    require 'csv'
    CSV.open("offsetters.csv", "w") do |csv|
      column_names = %w(Name Description Image)
      csv << column_names
      all.each do |awardee|
        csv << [awardee.name, awardee.description, awardee.avatar_file_name]
      end
    end
  end

end
