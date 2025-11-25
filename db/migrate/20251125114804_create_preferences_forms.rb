class CreatePreferencesForms < ActiveRecord::Migration[7.1]
  def change
    create_table :preferences_forms do |t|
      t.references :user_trip_status, null: false, foreign_key: true
      t.string :budget
      t.string :travel_pace
      t.text :interests
      t.text :activity_types

      t.timestamps
    end
  end
end
