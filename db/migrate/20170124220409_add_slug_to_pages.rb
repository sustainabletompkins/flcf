class AddSlugToPages < ActiveRecord::Migration
  def change
    add_column :pages, :slug, :text, :null=>:false
  end
end
