app.controller('CalendarController', ['$scope', '$http', 'UserItem', 'filterFilter', function($scope, $http, UserItem, filter) {
  $scope.error  = "";
  $scope.filter = filter;
  $scope.display_dates = [];
  $scope.user_items = {};
  $scope.items = [];
  $scope.datepicker_element;
  $scope.change_date = function(offset) {
    if (true == angular.isObject($scope.datepicker_element)) {
      if (0 == offset) {
        $scope.datepicker_element.datepicker("setDate", "0");
      } else {
        var d = $scope.datepicker_element.datepicker("getDate");
        $scope.datepicker_element.datepicker("setDate", d.ago(-offset));
      }
      $scope.set_display_dates($scope.datepicker_element.datepicker("getDate"));
    }
  };
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
  $scope.selected_date = function() {
    return $scope.display_dates[1];
  };
  $scope.set_display_dates = function(selected_date) {
    $scope.display_dates = [selected_date.ago(1), selected_date, selected_date.ago(-1)];
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
