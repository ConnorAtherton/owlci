class BuildsController < ApplicationController
  ACCEPTED_GITHUB_EVENTS = %w(ping pull_request)

  skip_before_action :verify_authenticity_token, only: :create
  before_action :validate_github_event

  def create
    # case @event.to_sym
    # when :ping then  process_hook
    # when :pull_request then enqueue_a_build
    # end

    if @event == 'ping'
      @repo.active = true
      @repo.hook_id = ping_params[:hook_id]
      if @repo.save
        head(:ok)
      else
        head(:internal_server_error)
      end
    else # pull_request
      return head(:ok) unless %w(opened synchronize).include? pull_request_params[:build][:action]
      if @repo.enqueue_build_from_github_webhook(pull_request_params)
        head(:ok)
      else
        head(:internal_server_error)
      end
    end
  end

  private

  def process_hook
    @repo.hook_id = ping_params[:hook_id]
    @repo.active = true

    if @repo.save
      head(:ok)
    else
      head(:internal_server_error)
    end
  end

  def enqueue_a_build
    return head(:ok) unless ["opened", "synchronize"].include? pull_request_params[:build][:action]

    if @repo.enqueue_build_from_github_webhook(pull_request_params)
      head(:ok)
    else
      head(:internal_server_error)
    end
  end

  def validate_github_event
    @event = request.headers['HTTP_X_GITHUB_EVENT']

    if @event.present? && ACCEPTED_GITHUB_EVENTS.include?(@event)
      @repo = Repo.find_by_full_name(params[:repository][:full_name])
      head(:not_found) unless @repo
    else
      head(:not_found)
    end
  end

  def ping_params
    params.permit(:hook_id)
  end

  def pull_request_params
    params.permit(
      :number,
      build: [
        :action
      ],
      pull_request: [
        :id,
        :title,
        :html_url,
        head: [
          :sha,
          repo: [
            :full_name,
            :ssh_url
          ]
        ],
        base: [
          :sha,
          repo: [
            :full_name,
            :ssh_url
          ]
        ]
      ]
    )
  end
end
