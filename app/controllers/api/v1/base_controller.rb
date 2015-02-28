class Api::V1::BaseController < ApplicationController
  before_filter :authenticated_user!

  protected

  def authenticated_user!
    render nothing: true, status: :unauthorized unless current_user
  end
end
