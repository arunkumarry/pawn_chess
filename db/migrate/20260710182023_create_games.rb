class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :status, default: "active"
      t.json :board_state
      t.integer :current_turn_player_id
      t.integer :winner_id

      t.timestamps
    end
  end
end
