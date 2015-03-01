class Build < ActiveRecord::Base
  belongs_to :repo

  enum state: [:not_started, :in_progress, :finished, :failed]
  serialize :results

  def self.create_from_github_webhook(pr)
    Build.create(
      action: pr[:action],
      number: pr[:number],
      head_sha: pr[:pull_request][:head][:sha],
      head_repo_full_name: pr[:pull_request][:head][:repo][:full_name],
      head_ssh_url: pr[:pull_request][:head][:repo][:ssh_url],
      base_sha: pr[:pull_request][:base][:sha],
      base_repo_full_name: pr[:pull_request][:base][:repo][:full_name],
      base_ssh_url: pr[:pull_request][:base][:repo][:ssh_url],
      title: pr[:pull_request][:title],
      html_url: pr[:pull_request][:html_url],
      state: :not_started
    )
  end

  def enqueue_build
    BuildWorker.perform_async(id)
  end

  def average_score
    results.map {|k, v| v}.inject(0) {|a, o| a + (100 - o[:score])} / results.count
  end
end
