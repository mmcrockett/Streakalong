app.controller('CalendarController', ['$scope', '$http', 'UserItems', function($scope, $http, UserItems) {
  $scope.selected_date;
  $scope.parse_date = function(d) {
    try {
      var parts = d.toDateString().split(" ");

      return parts;
    } catch(e) {
      try {
        return new Date().toDateString().split(" ");
      } catch(e) {
        return ["Mon", "Jan", "01", "1969"];
      }
    }
  };
  $scope.display_month_year = function(){
    var parts = $scope.parse_date($scope.selected_date);
    return parts[1] + " " + parts[3];
  };
  $scope.date_relative_to_selected = function(offset) {
    var day_in_millis = 24 * 60 * 60 * 1000;
    return new Date($scope.selected_date.valueOf() + day_in_millis * offset);
  };
  $scope.display_day_of_week = function(d) {
    var parts = $scope.parse_date(d);
    return parts[0];
  };
  $scope.display_month_day = function(d) {
    var parts = $scope.parse_date(d);
    return parts[1] + " " + d.getDate();
  };
  $scope.date_offsets = function() {
    return [-1, 0, 1];
  };
}]);
