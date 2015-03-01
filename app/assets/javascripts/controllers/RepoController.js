angular.module('controllers')

.controller('RepoController', ['$scope', 'RepoService', function($scope, RepoService) {

  $scope.requestInProgress = false;

  $scope.invertWebhook = function() {
    !!$scope.repo.active ? deleteHook() : createHook();
    $scope.requestInProgress = true;
  };

  function createHook() {
    RepoService.createHook($scope.repo).then(function(data) {
      $scope.repo.active = true;
      $scope.repo.id = data.id;
      $scope.repo.has_yml = data.has_yml;
      $scope.requestInProgress = false;
    }, function(err) {
      console.log('Err bro,', err);
    }, function() {
      $scope.requestInProgress = false;
    });
  }

  function deleteHook() {
    RepoService.deleteHook($scope.repo).then(function(data) {
      $scope.repo.active = false;
      $scope.repo.has_yml = false;
      $scope.requestInProgress = false;
    }, function(err) {
      $scope.repo.active = true;
      $scope.requestInProgress = false;
    }, function() {
      $scope.requestInProgress = false;
    });
  }

}]);
