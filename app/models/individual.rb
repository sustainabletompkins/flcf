class Individual < ActiveRecord::Base
  belongs_to :region
  has_many :offsets
  validates :name, uniqueness: true

  def offsets_since(date = nil)
    start = if date
              Date.strptime(date, '%m/%d/%y')
            else
              Date.strptime('1/1/15', '%m/%d/%y')
            end
    offsets.where('created_at > ? and purchased = ?', start, true).count
  end

  def pounds_since(date = nil)
    start = if date
              Date.strptime(date, '%m/%d/%y')
            else
              Date.strptime('1/1/15', '%m/%d/%y')
            end
    offsets.where('created_at > ? and purchased = ?', start, true).sum(&:pounds).round
  end
end
