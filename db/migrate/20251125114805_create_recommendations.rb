class CreateRecommendations < ActiveRecord::Migration[7.1]
  def change
    create_table :recommendations do |t|
      t.references :trip, null: false, foreign_key: true
      t.boolean :accepted
      t.text :system_prompt

      t.timestamps
    end
  end
end
