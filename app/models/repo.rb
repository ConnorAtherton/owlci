class Repo < ActiveRecord::Base
  belongs_to :user
  has_many :builds

  before_create :setup_hook, :add_collab
  before_destroy :teardown_hook, :remove_collab

  scope :order_by_active, -> { order("active DESC") }

  OWL_YML_PATH = '.owl.yml'

  def enqueue_build_from_github_webhook(pr)
    @build = builds.create_from_github_webhook(pr)
    @build.enqueue_build if @build
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

  def add_collab
    user.github.add_collab(full_name, 'owlci')
  end

  def remove_collab
    user.github.remove_collab(full_name, 'owlci')
  end

  def setup_hook
    hook = user.github.create_hook(
      full_name,
      'web',
      {
        url: callback_url,
        content_type: 'json'
      },
      {
        events: %w(pull_request),
        active: true
      }
    )

    self.hook_id = hook.id
  end

  def teardown_hook
    user.github.remove_hook(full_name, hook_id)
  end

  def callback_url
    ENV['SITE_URL'] + "/builds"
  end
end
