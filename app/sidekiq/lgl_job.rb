class LglJob
  include Sidekiq::Job

  def perform(email, amount, name, zip_code)
    require 'net/http'
    require 'uri'
    require 'json'
    uri = URI.parse('https://sustainabletompkins.littlegreenlight.com/integrations/e43d9598-3876-47a8-9411-9a6afdff1647/listener')
    data = { payment_type: 'Credit Card', email: email, amount: amount, name: name, zip_code: zip_code || 12_314, date: Date.today, fund: 'Finger Lakes Climate Fund' }
    puts uri, data
    puts 'performaing async task'
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.post(uri, data.to_json, { 'Content-Type' => 'application/json', 'Accept' => 'application/json' })
  end
end
