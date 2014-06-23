app.controller('CalendarController', ['$scope', '$http', 'UserItem', 'filterFilter', function($scope, $http, UserItem, filter) {
  $scope.error  = "";
  $scope.filter = filter;
  $scope.selected_date;
  $scope.user_items = {};
  $scope.items = [];
  $scope.isDayItem = function(category) {
    if (true == angular.isString(category)) {
      if ('daydata' == category) {
        return true;
      }
    }

    return false;
  };
  $scope.clear_error = function() {
    $scope.error = "";
  };
  $scope.setup_items = function(items) {
    $scope.items = items;
  };
  $scope.get_user_items = function(d) {
    $scope.user_items[d] = UserItem.query({date: d.getTime()});
  };
  $scope.date_relative_to_selected = function(offset) {
    var day_in_millis = 24 * 60 * 60 * 1000;
    return new Date($scope.selected_date.valueOf() + day_in_millis * offset);
  };
  $scope.date_offsets = function() {
    return [-1, 0, 1];
  };
  $scope.update_amount = function(amt, item_id, d) {
    var date_data = $scope.user_items[d];

    if (true == angular.isObject(date_data)) {
      var user_item = $scope.filter(date_data, {item_id: item_id})[0];

      if (true == angular.isObject(user_item)) {
        var old_amt = user_item.amount;
        user_item.amount += amt;
        user_item.$update({}, $scope.clear_error, function(v){user_item.amount = old_amt;$scope.error = "Sorry, there was an issue saving data.";});
      } else {
        user_item = new UserItem({amount: amt, date: d, item_id: item_id});
        user_item.$save({}, function(v){date_data.push(user_item);$scope.clear_error();},function(v){$scope.error = "Sorry, there was an issue saving data.";});
      }
    } else {
      log.warning("Still loading data...");
    }
  };
}]);
