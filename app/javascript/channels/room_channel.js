import consumer from "./consumer"

window.subscribeToRoom = function(roomId) {
  return consumer.subscriptions.create(
    { channel: "RoomChannel", room_id: roomId },
    {
      received(data) {
        if (data.players_html) {
          $("#players").html(data.players_html);
        }
        if (typeof data.player_count !== "undefined") {
          $(`[data-room-count-id='${roomId}']`).text(`${data.player_count}/6`);
        }
      }
    }
  );
}
