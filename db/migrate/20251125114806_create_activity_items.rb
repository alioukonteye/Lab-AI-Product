class CreateActivityItems < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_items do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :reservation_url
      t.string :activity_type

      t.timestamps
    end
  end
end
