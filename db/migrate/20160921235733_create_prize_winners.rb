class CreatePrizeWinners < ActiveRecord::Migration
  def change
    create_table :prize_winners do |t|
      t.string :email
      t.belongs_to :prize
      t.string :code
      t.boolean :claimed, :default => :false
    end
  end
end
