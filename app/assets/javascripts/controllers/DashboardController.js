angular.module('controllers')

.controller('DashboardController', ['$scope', 'RepoService', function($scope, RepoService) {
  $scope.repos = undefined;

  RepoService.all().then(function(data) {
    $scope.repos = data;
    $scope.styleClass = "is-loaded";
  });

}]);
