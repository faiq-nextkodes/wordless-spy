import consumer from "./consumer"

window.subscribeToRoom = roomId => consumer.subscriptions.create(
  { channel: "RoomChannel", room_id: roomId },
  {
    received(data) {
      if (data.players_html) $("#players").html(data.players_html);
      if (data.player_count !== undefined)
        $(`[data-room-count-id='${roomId}']`).text(`${data.player_count}/6`);

      data.show_start_button ? renderStartButton(data.button_data) : $("#button-container").empty();
      if (data.show_game_data) showGameModal(data.modal_game_data);
    }
  }
);

const getCurrentUserId = () => window.gameData?.currentUserId || null;

function renderStartButton({ owner_id, game_id }) {
  if (owner_id != getCurrentUserId()) return $("#button-container").empty();

  $("#button-container").html(`
    <form class="button_to" method="post" action="/games/${game_id}/start">
      <input type="submit" value="Start Game" 
        class="btn btn-success btn-lg start-btn" 
        data-turbo-prefetch="false" />
    </form>
  `);
}

function showGameModal({ spy_id, villagers_word, category }) {
  const isSpy = getCurrentUserId() && spy_id && getCurrentUserId() == spy_id;
  const wordToShow = isSpy ? "---" : villagers_word;

  const modalHtml = `
    <div id="game-start-modal" class="modal fade show" style="display: block; background-color: rgba(0,0,0,0.5);" tabindex="-1">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header bg-success text-white">
            <h5 class="modal-title">Game has started!</h5>
          </div>
          <div class="modal-body text-center">
            <div class="mb-3"><h5><strong>Category:</strong> ${category}</h5></div>
            <div class="mb-3">
              <h4><strong>Your Word:</strong></h4>
              <h2 class="text-primary">${wordToShow}</h2>
            </div>
            ${isSpy ? '<p class="text-danger"><strong>You are the SPY!</strong></p>' : ''}
          </div>
        </div>
      </div>
    </div>
  `;
  
  $("#game-start-modal").remove();
  $("body").append(modalHtml);
  setTimeout(() => { $("#game-start-modal").fadeOut(300, function() { $(this).remove(); }); }, 5000);

  $("#game-info").html(`
    <div class="card shadow-sm p-3">
      <h4 class="mb-3">Category: ${category}</h4>
      <h3 class="fw-bold">${wordToShow}</h3>
    </div>
  `);
}
