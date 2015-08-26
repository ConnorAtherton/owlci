angular.module('services')

.factory('RepoService', ['Restangular', function(Restangular) {

  var repos = Restangular.all('repos');

  return {
    all: function() {
      return repos.getList().then(function(data) {
        return data;
      });
    },

    createHook: function(repo) {
      return repos.post({repo: repo}).then(function(res) {
        return res;
      });
    },

    deleteHook: function(repo) {
      return repo.remove().then(function(res) {
        return res;
      })
    }
  }
}]);
