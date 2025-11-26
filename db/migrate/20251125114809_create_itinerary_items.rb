class CreateItineraryItems < ActiveRecord::Migration[7.1]
  def change
    create_table :itinerary_items do |t|
      t.references :itinerary, null: false, foreign_key: true
      t.references :activity_item, null: false, foreign_key: true
      t.integer :day
      t.string :slot
      t.time :time
      t.integer :position

      t.timestamps
    end
  end
end
