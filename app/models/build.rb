class Build < ActiveRecord::Base
  belongs_to :repo

  enum state: [:not_started, :in_progress, :finished, :failed]
  serialize :results

  def self.create_from_github_webhook(pr)
    Build.create(
      action: pr[:build][:action],
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

  def update_github_pr_status(state, desc)
    repo.user.github.create_status(repo.full_name, head_sha, state,
      context: "owl", description: desc)
  end

  def set_state state
    self.state = state
    if state == :in_progress
      update_github_pr_status("pending", "Owl is eyeing the changes")
    elsif state == :finished
      update_github_pr_status("success", "Owl has eyed the changes")
      reply_to_gihub_pr_with_shots
    elsif state == :failed
      update_github_pr_status("error", "Owl needs glasses")
    end
  end

  def set_state! state
    set_state state
    save!
  end

  def reply_to_gihub_pr_with_shots
    return unless finished?
    body = <<-EOF
Label | Route | Base | Head | Diff
----- | ----- | ---- | ---- | ---
EOF
    results.each do |label, result|
      thumbs = result[:thumbs_path].gsub /^\/public/, ''
      base = File.join("http://owlci.beta.ngrok.com", thumbs, result[:base])
      head = File.join("http://owlci.beta.ngrok.com", thumbs, result[:head])
      diff = File.join("http://owlci.beta.ngrok.com", thumbs, result[:diff])
      body += [
        label,
        result[:route],
        "![Base](#{base})",
        "![Head](#{head})",
        "![Diff](#{diff}) (#{result[:score].to_s}% different)"
      ].join(" | ") + "\n"
    end
    OwlCI.github.add_comment(repo.full_name, number, body)
  end

  private

end
