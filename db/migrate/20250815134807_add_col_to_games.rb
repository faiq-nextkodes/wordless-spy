class AddColToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :category, :string
    add_reference :games, :spy, null: true, foreign_key: { to_table: :users }
  end
end
