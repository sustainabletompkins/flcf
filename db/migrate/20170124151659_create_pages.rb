class CreatePages < ActiveRecord::Migration[5.1]
  def change
    create_table :pages do |t|
      t.text :body, :null=>:false
      t.string :title, :null=>:false
      t.boolean :published
      t.boolean :menu
      t.timestamps
    end
  end
end
