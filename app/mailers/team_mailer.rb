class TeamMailer < ActionMailer::Base


  default from: "Finger Lakes Climate Fund <info@sustainabletompkins.org>"
  default :to => ""

  def send_thanks(email, team)
    @team = team
    mail(:subject => "Your Contribution to #{@team.name.upcase}", :to => email) if @team.id == 14
  end


end
