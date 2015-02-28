class Api::V1::UserSessionsController < Api::V1::BaseController
  respond_to :html, :json

  def show
    @current_user = current_user
    respond_with @current_user
  end

  def delete
    session.delete(:user_id)
    render nothing: true, status: :ok
  end
end
