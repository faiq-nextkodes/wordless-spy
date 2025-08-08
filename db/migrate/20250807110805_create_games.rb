class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.references :room, null: false, foreign_key: true

      t.string :villagers_word

      t.string :words_list, array: true, default: []
      t.jsonb :players_hash, default: { 1 => nil, 2 => nil, 3 => nil, 4 => nil, 5 => nil, 6 => nil }

      t.integer :status, null: false, default: 0
      t.integer :result

      t.timestamps
    end
  end
end
