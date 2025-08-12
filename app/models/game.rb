class Game < ApplicationRecord
  ALLOWED_TRANSITIONS = {
    "room_assigned" => "started",
    "started"       => "finished"
  }.freeze

  validate :status_transition_is_valid, if: :will_save_change_to_status?

  after_save :start_new_game, if: :finished?

  belongs_to :room

  enum :status, { room_assigned: 0, started: 1, finished: 2 }
  enum :result, { spy_won: 0, spy_lost: 1 }

  def join_game(player)
    return errors.add(:base, "You are already in this room.") && false if players_hash.value?(player)

    slot = players_hash.key(nil)
    return errors.add(:base, "The room is full. You cannot join.") && false unless slot

    players_hash[slot] = player
    save && broadcast_players_update
  end

  def leave_game(player)
    if (slot = players_hash.key(player))
      players_hash[slot] = nil
      save
      broadcast_players_update
    end
  end

  private

  def status_transition_is_valid
    from, to = status_change_to_be_saved
    errors.add(:status, "cannot transition from #{from} to #{to}") unless ALLOWED_TRANSITIONS[from] == to
  end

  def start_new_game
    room.assign_new_game
  end

  def broadcast_players_update
    player_count = players_hash.values.compact.size

    ActionCable.server.broadcast(
      "room_#{room_id}_channel",
      {
        players_html: ApplicationController.renderer.render(
          partial: "rooms/player_list",
          locals: { players_hash: players_hash }
        ),
        player_count: player_count
      }
    )
  end
end
