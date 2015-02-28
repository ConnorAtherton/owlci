class Repo < ActiveRecord::Base
  belongs_to :user

  before_save :setup_hook
  before_destroy :teardown_webook

  private

  def setup_hook
    hook = user.github.create_hook(
      full_name,
      'web',
      {
        url: "http://owlci.club/builds",
      },
      {
        events: ["pull_request"],
        active: true
      }
    )
    self.hook_id = hook.id
  end

  def teardown_webook
    user.github.remove_hook(full_name, hook_id)
  end
end
