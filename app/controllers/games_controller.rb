class GamesController < ApplicationController
  before_action :set_game, only: %i[ start ]

  def start
    @game.initialize_new_game
  end

  private

  def set_game
    @game = Game.find_by(id: params[:id])
  end
end
