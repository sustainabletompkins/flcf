class AddEmailToIndividuals < ActiveRecord::Migration[5.1]
  def change
    add_column :individuals, :email, :string
  end
end
