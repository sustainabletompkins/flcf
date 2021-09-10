namespace :maintenance do
  desc 'organize previous offsets onto teams'
  task organize_offsets: :environment do
    TeamMember.all.each do |tm|
      offsets = Offset.where(email: tm.email, purchased: true).order(created_at: :desc).limit(tm.offsets)
      offsets.update_all(team_id: tm.team_id)
    end
  end

  task reassign_prize_images: :environment do
    Dir.foreach('lib/assets/images') do |filename|
      if filename.match?(/(jpeg|png)/)
        prize = filename.split('.')[0].gsub('_', ' ')
        puts prize
        p = Prize.find_by_title(prize)
        puts p.inspect
        File.open('lib/assets/images/' + filename) do |io|
          p.image.attach(io: io, filename: filename)
        end

      end
    end
  end
end
