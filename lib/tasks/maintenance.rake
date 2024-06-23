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

  task update_purchased: :environment do
    # Find all purchased CartItems
    purchased_cart_items = CartItem.where(purchased: true)

    purchased_cart_items.find_each do |cart_item|
      # Find corresponding offsets with the same checkout_session_id
      offsets = Offset.where(checkout_session_id: cart_item.checkout_session_id)
      
      offsets.find_each do |offset|
        # Update each offset to purchased: true
        offset.update(purchased: true)
        puts "Updated Offset ID: #{offset.id} to purchased: true"
      end
    end

    puts "All corresponding offsets have been updated."
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
