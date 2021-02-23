class PrizeWinnerSerializer < ActiveModel::Serializer
  attributes :email, :name, :claimed, :date, :prize
  
  def date
    return object.created_at.strftime('%m-%d-%y')
  end

  def prize
    return ActiveModelSerializers::SerializableResource.new(object.prize, serializer: PrizeSerializer)
  end
end
