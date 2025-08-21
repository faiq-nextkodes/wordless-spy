class Game < ApplicationRecord
  ALLOWED_TRANSITIONS = {
    "room_assigned" => "started",
    "started"       => "finished"
  }.freeze

  validate :status_transition_is_valid, if: :will_save_change_to_status?

  after_save :start_new_game, if: :finished?

  has_one :spy, class_name: "User"

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

  def initialize_new_game
    service = WordlessSpy::OpenAiWordService.new

    data = service.fetch_words

    category = data.keys.first
    word_list = data[category]

    update!(status: :started, category: category, words_list: word_list, villagers_word: word_list.sample, spy_id: players_hash.values.sample)

    broadcast_game_start_modal
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
    broadcast_start_button
  end

  def broadcast_start_button
    ActionCable.server.broadcast(
      "room_#{room_id}_channel",
      {
        show_start_button: !players_hash.values.any?(nil),
        button_data: {
          game_id: id,
          owner_id: players_hash["1"]
        }
      }
    )
  end

  def broadcast_game_start_modal
    ActionCable.server.broadcast(
      "room_#{room_id}_channel",
      {
        show_game_data: true,
        modal_game_data: {
          spy_id: spy_id,
          category: category,
          villagers_word: villagers_word
        }
      }
    )
  end
end
