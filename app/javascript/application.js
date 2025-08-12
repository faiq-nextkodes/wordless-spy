import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
import "channels"
import "jquery"

$(function () {
  $('[data-bs-toggle="tooltip"]').each(function () {
    new bootstrap.Tooltip(this)
  })
})

window.roomSubscription = null;

$(document).on("turbo:load", function () {
  const $roomElement = $("#room-id");
  if ($roomElement.length === 0) return; // no room on this page

  const roomId = $roomElement.data("room-id");

  if (window.roomSubscription) {
    window.roomSubscription.unsubscribe();
  }

  window.roomSubscription = subscribeToRoom(roomId);
});
