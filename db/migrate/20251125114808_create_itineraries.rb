class CreateItineraries < ActiveRecord::Migration[7.1]
  def change
    create_table :itineraries do |t|
      t.references :trip, null: false, foreign_key: true
      t.text :system_prompt

      t.timestamps
    end
  end
end
