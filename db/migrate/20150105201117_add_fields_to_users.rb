class AddFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :first_name, :string

    add_column :users, :username, :string, :null => :false

    add_column :users, :about, :string

  end
end
