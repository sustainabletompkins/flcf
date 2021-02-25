namespace :maintenance do
  desc "organize previous offsets onto teams"
  task :organize_offsets => :environment do
     TeamMember.all.each do |tm|
      offsets = Offset.where(:email=>tm.email, :purchased=>true).order(created_at: :desc).limit(tm.offsets)
      offsets.update_all(:team_id => tm.team_id)
     end
  end
end