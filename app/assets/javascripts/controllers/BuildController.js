angular.module('controllers')

.config(function($stateProvider) {

  $stateProvider
    .state('builds', {
      url: "/:user/:repo",
      params: {
        repo_obj: null
      },
      controller: 'BuildController',
      templateUrl: "builds.html"
    });
})

.controller('BuildController', function($scope, $stateParams, Restangular) {

  $scope.selectedBuild = undefined;
  $scope.styleClass = undefined;

  var full_name = ($stateParams.user + '/' + $stateParams.repo)
  var repo_obj = $stateParams.repo_obj || Restangular.one('repos', full_name );

  repo_obj.get().then(function(data) {
    $scope.builds = data;
    $scope.selectedBuild = $scope.builds[0];
    $scope.loaded = true;
    $scope.styleClass = "buildLoaded";
  });

  $scope.successMeasure = function(score) {
    score = 100 - score;

    if (score > 85) return "good";
    if (score > 60) return "okay";

    return "bad";
  }

});
