class AddSessionIdToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :session_id, :string
  end
end
