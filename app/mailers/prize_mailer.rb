class PrizeMailer < ActionMailer::Base


  default from: "info@sustainabletompkins.org"
  default :to => ""

  def send_prize_details(email, code, business, description)
    @code = code
    @description = description
    @business = business
    mail(:subject => 'How to claim your prize', :to => email)
  end


end
