angular.module('services')

.factory('RepoService', ['Restangular', function(Restangular) {

  var repos = Restangular.all('repos');

  return {
    all: function() {
      return repos.getList().then(function(data) {
        return data;
      });
    }
  }

}]);
