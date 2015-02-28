class User < ActiveRecord::Base
  has_many :repos

  def self.find_or_create_from_auth_hash auth_hash
    @user = User.find_or_initialize_by(email: auth_hash["info"]["email"])
    @user.name = auth_hash["info"]["name"]
    @user.username = auth_hash["info"]["nickname"]
    @user.avatar = auth_hash["info"]["image"]
    @user.access_token = auth_hash["credentials"]["token"]
    if @user.save
      @user
    else
      raise StandardError, "Authentication Failed"
    end
  end

  def github
    @github ||= Octokit::Client.new access_token: access_token
  end
end
