class GamesController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create, :move ]

  def create
    game = Game.start_game(
      player1_name: params[:player1_name] || "ABC",
      player2_name: params[:player2_name] || "XYZ"
    )
    render json: game_params(game), status: :created
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # get - /games/:id
  def show
    game = Game.find(params[:id])
    render json: game_params(game)
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Game not found" }, status: :not_found
  end

  # move - /games/:id/move
  def move
    game = Game.find(params[:id])
    player = game.players.find(params[:player_id])

    from_row = params[:from_row]&.to_i
    from_col = params[:from_col]&.to_i
    to_row = params[:to_row]&.to_i
    to_col = params[:to_col]&.to_i

    if game.play(player, from_row, from_col, to_row, to_col)
      # bot's turn
      while game.current_turn_player&.bot? && !game.game_over?
        game.play(game.current_turn_player)
      end

      render json: game_params(game)
    else
      render json: { error: "Invalid move" }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: e.message }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def game_params(game)
    {
      id: game.id,
      status: game.status,
      board_state: game.board_state,
      current_turn_player: player_params(game.current_turn_player),
      winner: player_params(game.winner),
      players: game.players.map { |p| player_params(p) }
    }
  end

  def player_params(player)
    return nil if player.nil?

    {
      id: player.id,
      name: player.name,
      player_type: player.player_type,
      indicator: player.indicator,
      moves_history: player.moves_history,
      pawns_count: player.pawns_count
    }
  end
end
