namespace :scheduler do
  desc "This task is called by the Heroku cron add-on"
  task :call_page => :environment do
     require "net/http"
     uri = URI.parse('https://boiling-spire-1619.herokuapp.com/')
     Net::HTTP.get(uri)
  end
end