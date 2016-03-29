class Api::V1::ReposController < Api::V1::BaseController
  def index
    @repos = []

    current_user.github.repos
      .select! { |repo| repo.permissions.admin }
      .map do |r|
        repo = Repo.find_or_initialize_by(full_name: r.full_name)
        repo.attributes = r.attrs.slice(:ssh_url, :html_url, :stargazers_count, :language, :private)
        repo.save unless repo.id.nil?

        repo
      end
      .sort! { |a, b| b.stargazers_count <=> a.stargazers_count }
      .each { |r| r.active ? @repos.unshift(r) : @repos.push(r) }
  end

  def show
    if params[:user] && params[:repo]
      params[:id] = "#{params[:user]}/#{params[:repo]}"
    end

    @repo = current_user.repos.find_by_id params[:id]
    @builds = @repo.nil? ? [] : @repo.builds.reverse
  end

  def create
    params = repo_params
    @repo = Repo.new(params)

    if @repo.save
      render 'api/v1/repos/create'
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
    permitted = [:id, :full_name, :private, :html_url, :ssh_url, :user_id]
    params[:repo].merge(user_id: current_user.id).permit(permitted)
  end
end
