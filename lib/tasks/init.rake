namespace :init do
  desc "This task is called by the Heroku cron add-on"
  task :seed_prizes => :environment do
    Prize.destroy_all
    Prize.create(:title=>'Cinemapolis', :description => '1 movie pass',:count=>8)
    Prize.create(:title=>'Ithaca Bakery', :description => '$5 Gift Certificate',:count=>8)
    Prize.create(:title=>'Autumn Leaves', :description => '$5 Gift Certificate',:count=>10)
    Prize.create(:title=>'Waffle Frolic', :description => '$5 Gift Card',:count=>4)

  end

  task :set_codes => :environment do
    Prize.all.each do |p|
      p.count.times do
        code = (0...8).map { (65 + rand(26)).chr }.join
        PrizeWinner.create(:code=>code, :prize_id=>p.id)
      end

    end
  end

  task :set_stats => :environment do
    Stat.create(:pounds=>'3472400' , :dollars => '33092', :awardees => '18')
  end
end