class CreateMessageTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :message_templates do |t|
      t.string :name
      t.text :body
      t.boolean :active
    end
  end
end
