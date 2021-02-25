class CreateRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :regions do |t|
      t.string :name
      t.string :counties
      t.text :zipcodes, :array=>true, :default=>[]
    end
  end
end
