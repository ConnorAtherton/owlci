class SessionsController < ApplicationController
  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    session[:user_id] = @user.id
    # TODO make this a route
    redirect_to '/dashboard'
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end
end
