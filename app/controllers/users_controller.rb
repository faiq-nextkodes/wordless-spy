class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[ dashboard ]

  def dashboard
    @rooms = Room.includes(:user).latest(10)
  end
end
