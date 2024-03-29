namespace :maintenance do
  desc 'organize previous offsets onto teams'
  task organize_offsets: :environment do
    TeamMember.all.each do |tm|
      offsets = Offset.where(email: tm.email).order(created_at: :desc).limit(tm.offsets)
      offsets.update_all(team_id: tm.team_id)
    end
  end

  task clean_teams: :environment do
    Team.all.each do |team|
      team.update_offset_count
      team.destroy if team.offsets.count == 0
    end
  end

  task consolidate_team_members: :environment do
    Team.all.each do |team|
      team.team_members.each do |tm|
        # make sure number is correct
        tm.count_offsets
        duplicates = team.team_members.where(email: tm.email)
        offsets = tm.offsets
        duplicates.each do |dup|
          next if dup.id == tm.id

          tm.email
          offsets += dup.offsets
          dup.destroy
        end
        tm.update_attribute(:offsets, offsets)
      end
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
