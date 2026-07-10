class CreatePlayers < ActiveRecord::Migration[8.1]
  def change
    create_table :players do |t|
      t.string :name
      t.string :player_type
      t.integer :indicator
      t.json :moves_history, default: []
      t.integer :pawns_count, default: 16
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
