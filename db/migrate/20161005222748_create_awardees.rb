class CreateAwardees < ActiveRecord::Migration
  def change
    create_table :awardees do |t|
      t.string :name
      t.text :bio
      t.string :video_id
      t.string :img_url
      t.integer :award_amount
      t.integer :pounds_offset
      t.datetime :award_date
    end
  end
end
