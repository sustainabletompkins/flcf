class AddSecretToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :api_secret, :string, :default=>nil
  end
end
