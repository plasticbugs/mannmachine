class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.text :custom_description
      t.string :custom_author
      t.text :custom_keywords
      t.string :custom_category
      t.string :custom_subcategory

      t.timestamps
    end
  end
end
