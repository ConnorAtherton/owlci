angular.module('controllers')

.controller('RepoController', ['$scope', 'RepoService', function($scope, RepoService) {

  $scope.requestInProgress = false;

  $scope.invertWebhook = function() {
    $scope.requestInProgress = true;

    RepoService.createHook($scope.repo).then(function(data) {
      $scope.repo.status = 'tracking';
    }, function(err) {
      console.log('Err bro,', err);
    }, function() {
      $scope.requestInProgress = false;
    });
  };

}]);
