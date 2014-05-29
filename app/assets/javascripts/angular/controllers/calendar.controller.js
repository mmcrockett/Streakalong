app.controller('CalendarController', ['$scope', '$http', 'UserItems', function($scope, $http, UserItems) {
  $scope.selected_date;
  $scope.display_selected_date = function(){
    try {
      var parts = $scope.selected_date.toDateString().split(" ");

      return parts[1] + " " + parts[3];
    } catch(e) {
      return "";
    }
  };
}]);
