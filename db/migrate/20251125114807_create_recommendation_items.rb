class CreateRecommendationItems < ActiveRecord::Migration[7.1]
  def change
    create_table :recommendation_items do |t|
      t.references :recommendation, null: false, foreign_key: true
      t.references :activity_item, null: false, foreign_key: true
      t.integer :like

      t.timestamps
    end
  end
end
