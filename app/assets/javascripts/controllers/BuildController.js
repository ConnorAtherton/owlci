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
  $scope.styleClass = undefined;

  var repo_obj = $stateParams.repo_obj;
  var full_name = ($stateParams.user + '/' + $stateParams.repo).replace('/', '_');

  // not nicest soltuion but it works
  if (repo_obj !== null) {
    repo_obj.get().then(function(data) {
      $scope.builds = data;
      $scope.selectedBuild = $scope.builds[0];
      $scope.styleClass = "buildLoaded";
    });
  } else {
    var repo = Restangular.one('repos', full_name );

    repo.get({use_full_name: true}).then(function(data) {
      $scope.builds = data;
      $scope.selectedBuild = $scope.builds[0];
      $scope.styleClass = "buildLoaded";
    });
  }

  $scope.successMeasure = function(score) {
    score = 100 - score;

    if (score > 85) return "good";
    if (score > 60) return "okay";

    return "bad";
  }

}]);
