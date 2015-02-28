class Repo < ActiveRecord::Base
  belongs_to :user
  has_many :builds

  before_create :setup_hook
  before_destroy :teardown_hook

  def enqueue_build_from_github_webhook(pr)
    @build = builds.create_from_github_webhook(pr)
    if @build
      @build.enqueue_build
    end
  end

  private

  def setup_hook
    hook = user.github.create_hook(
      full_name,
      'web',
      {
        url: "http://owlci.alpha.ngrok.com/builds",
        content_type: 'json'
      },
      {
        events: ["pull_request"],
        active: true
      }
    )
    self.hook_id = hook.id
  end

  def teardown_hook
    user.github.remove_hook(full_name, hook_id)
  end
end
