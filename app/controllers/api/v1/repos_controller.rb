class Api::V1::ReposController < Api::V1::BaseController

  def index
    # TODO issue one db query and compare that way instead
    @repos = current_user.github.repos
    @repos.each do |r|
      if (repo = current_user.repos.find_by_full_name r[:full_name])
        r[:active] = true
        r[:id] = repo.id
      else
        # because github send their own id
        r[:id] = nil
      end
    end

    @repos.select! { |repo| repo.permissions.admin }
          .sort! { |a, b| b.stargazers_count <=> a.stargazers_count }
  end

  def create
    params = repo_params
    @repo = Repo.new(params)

    if @repo.save
      render 'api/v1/repos/show'
    else
      render status: :error
    end
  end

  def destroy
    repo = current_user.repos.find params[:id]
    repo.destroy
    render nothing: true, status: :ok
  end

  private

  def repo_params
    permitted = [:full_name, :private, :html_url, :ssh_url, :user_id]
    params[:repo].merge(user_id: current_user.id).permit(permitted)
  end
end
