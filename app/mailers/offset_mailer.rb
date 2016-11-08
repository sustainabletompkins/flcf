class OffsetMailer < ActionMailer::Base


  default from: "Finger Lakes Climate Fund <info@sustainabletompkins.org>"
  default :to => ""

  def send_offset_details(email, offsets)
    @offsets = offsets
    mail(:subject => 'Your FLCF Carbon Offsets', :to => email)
  end


end
