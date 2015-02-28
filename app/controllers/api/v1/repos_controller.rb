class Api::V1::ReposController < Api::V1::BaseController

  def index
    # TODO find repos we have a hook set up for
    # and merge with all repos below
    @repos = current_user.github.repos
    @repos.sort! { |a, b| b.stargazers_count <=> a.stargazers_count }
          .select { |repo| repo.permissions.admin }
  end

end
