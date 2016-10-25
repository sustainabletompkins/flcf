class CreateOffsetters < ActiveRecord::Migration
  def change
    create_table :offsetters do |t|
      t.string :name, :null=>:false
      t.string :description, :null=>:false
    end
  end
end
