class OffsetSerializer < ActiveModel::Serializer
  attributes :id, :title, :pounds, :cost, :name, :zipcode, :created_at

  def created_at
    return object.created_at.strftime('%m-%d-%y')
  end
end
