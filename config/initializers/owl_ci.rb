class OwlCI
  class << self
    def github
      @@github ||= Octokit::Client.new access_token: ENV['GITHUB_OWLCI_ACCESS_TOKEN']
    end
  end
end
