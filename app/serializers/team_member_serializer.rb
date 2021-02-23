class TeamMemberSerializer < ActiveModel::Serializer
  attributes :id, :email, :name, :offsets, :is_founder, :join_date, :last_offset_date

  def is_founder
    return object.founder ? true : false
  end

  def join_date
    return object.created_at.strftime('%m-%d-%y')
  end

  def last_offset_date
    return object.updated_at.strftime('%m-%d-%y')
  end
end
