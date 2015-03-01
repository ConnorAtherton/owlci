class Api::V1::ReposController < Api::V1::BaseController

  def index
    @repos = []
    active = []

    current_user.github.repos
      .select! { |repo| repo.permissions.admin }
      .map do |r|
         repo = Repo.find_or_initialize_by(full_name: r.full_name)
         repo.attributes = r.attrs.slice(:ssh_url, :html_url, :stargazers_count, :language, :private)
         repo.save unless repo.id.nil?

         repo
      end
      .sort! { |a, b| b.stargazers_count <=> a.stargazers_count }
      .each { |r| r.active ? active.push(r) : @repos.push(r) }

    @repos = active.concat @repos
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
