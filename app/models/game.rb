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

  private

  def status_transition_is_valid
    from, to = status_change_to_be_saved
    errors.add(:status, "cannot transition from #{from} to #{to}") unless ALLOWED_TRANSITIONS[from] == to
  end

  def start_new_game
    room.assign_new_game
  end
end
