class TeamMember < ActiveRecord::Base
  belongs_to :team
  def count_offsets
    offset_count = Offset.where(email: email, team_id: team_id).count
    update_attribute(:offsets, offset_count)
  end

  def offsets_since(date = nil)
    start = if date
              Date.strptime(date, '%m/%d/%y')
            else
              Date.strptime('1/1/15', '%m/%d/%y')
            end
    team.offsets.where('email = ? AND created_at > ?', email, start).count
  end
end
