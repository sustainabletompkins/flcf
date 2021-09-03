class PrizeSerializer < ActiveModel::Serializer
  attributes :title, :description, :image

  def image
    'https:' + object.avatar.url
  end
end
