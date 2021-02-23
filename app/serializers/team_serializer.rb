class TeamSerializer < ActiveModel::Serializer
  attributes :id, :name, :members, :pounds, :offset_count

  def offset_count
    return object.count
  end
end
