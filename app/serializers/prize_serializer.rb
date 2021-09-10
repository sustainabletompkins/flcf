class PrizeSerializer < ActiveModel::Serializer
  attributes :title, :description, :image

  def image
    object.image.service_url.split('?').first
  end
end
