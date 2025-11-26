class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recommendation_item, null: false, foreign_key: true
      t.boolean :liked

      t.timestamps
    end
  end
end
