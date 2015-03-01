angular.module('controllers')

.config(['$stateProvider', function myAppConfig($stateProvider) {

  $stateProvider
    .state('builds', {
      url: "/:user/:repo",
      params: {
        repo_obj: null
      },
      controller: 'BuildController',
      templateUrl: "builds.html"
    });
}])

.controller('BuildController', ['$scope', '$stateParams', 'Restangular',
    function($scope, $stateParams, Restangular) {

  $scope.selectedBuild = undefined;

  var repo_obj = $stateParams.repo_obj;
  var full_name = ($stateParams.user + '/' + $stateParams.repo).replace('/', '_');

  // not nicest soltuion but it works
  if (repo_obj !== null) {
    repo_obj.get().then(function(data) {
      $scope.builds = data;
      $scope.selectedBuild = $scope.builds[0];
    });
  } else {
    var repo = Restangular.one('repos', full_name );

    repo.get({use_full_name: true}).then(function(data) {
      $scope.builds = data;
      $scope.selectedBuild = $scope.builds[0];
    });
  }

  $scope.open = function(first, second) {
    var scope = {
      src: first + second
    }
    ngDialog.open({ template: 'popupTmpl.html', scope: scope });
  }
}]);
