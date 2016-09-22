class PrizeMailer < ActionMailer::Base


  default from: "info@sustainabletompkins.org"
  default :to => ""

  def send_prize_details(email, code, description)
    @code = code
    @description = description
    mail(:subject => 'How to claim your prize', :to => email)
  end


end
