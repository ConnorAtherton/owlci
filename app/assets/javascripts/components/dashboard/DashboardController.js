angular.module('Dashboard', [])

.config(['$stateProvider', function($stateProvider) {

  $stateProvider
    .state('dashboard', {
      url: '/dashboard',
      controller: 'DashboardController',
      templateUrl: 'dashboard/dashboard.tpl.html'
    });
}])

.controller('DashboardController', ['$scope', function() {

}]);
