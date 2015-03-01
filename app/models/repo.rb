class Repo < ActiveRecord::Base
  belongs_to :user
  has_many :builds

  before_create :setup_hook
  before_destroy :teardown_hook

  scope :order_by_active, -> { order("active DESC") }

  OWL_YML_PATH = '.owl.yml'

  def enqueue_build_from_github_webhook(pr)
    @build = builds.create_from_github_webhook(pr)
    if @build
      @build.enqueue_build
    end
  end

  def name
    full_name.split("/").last
  end

  def has_owl_yml?
    !!(user.github.contents full_name, path: OWL_YML_PATH)
  rescue Octokit::NotFound
    nil
  end

  private

  def setup_hook
    hook = user.github.create_hook(
      full_name,
      'web',
      {
        url: File.join(Rails.application.secrets.site_url, "/builds"),
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
