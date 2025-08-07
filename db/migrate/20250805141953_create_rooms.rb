class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :rooms, :name, unique: true
  end
end
