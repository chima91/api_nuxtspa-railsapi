class Api::V1::UsersController < ApplicationController
  before_action :authenticate_active_user

  def index
    users = User.all
    render json: users.as_json(only: [:id, :name, :email, :created_at])
  end
end
