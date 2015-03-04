class ErrorsController < ApplicationController

  def show
    render view, status: status_code
  end

  private

  def status_code
    params[:status] || 500
  end

  def view
    status_code.to_s
  end
end
