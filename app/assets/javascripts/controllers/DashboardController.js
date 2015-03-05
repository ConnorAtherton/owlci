angular.module('controllers')

.controller('DashboardController', function($scope, RepoService) {
  $scope.repos = undefined;

  RepoService.all().then(function(data) {
    $scope.repos = data;
    $scope.styleClass = "reposLoaded";
  });

});
