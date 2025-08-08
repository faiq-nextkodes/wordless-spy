class AddColToRooms < ActiveRecord::Migration[8.0]
  def change
    add_reference :rooms, :current_game, foreign_key: { to_table: :games }, null: true, index: { unique: true }
  end
end
