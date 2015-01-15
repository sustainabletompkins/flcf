class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :offsets

  after_create :load_offsets_from_session

  private

  def load_offsets_from_session
    puts "creating user"
    puts self.session_id
    @user_offsets = Offset.where(:session_id => self.session_id)
    @user_offsets.each do |o|
      o.user_id = self.id
      o.save
    end
  end

end
