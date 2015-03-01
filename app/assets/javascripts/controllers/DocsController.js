angular.module('controllers')

.config(['$stateProvider', function myAppConfig($stateProvider) {

  $stateProvider
    .state('docs', {
      url: "/docs",
      templateUrl: "docs.html",
    });
}])

.controller('DocsController', ['$scope', function($scope) {

}]);
