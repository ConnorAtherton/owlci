class Api::V1::BuildsController < Api::V1::BaseController
  def show
    @builds = current_user
  end
end
