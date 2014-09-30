app.controller('CalendarController', ['$scope', '$http', '$interval', 'UserItem', 'User', 'filterFilter', function($scope, $http, $interval, UserItem, User, filter) {
  $scope.error  = "";
  $scope.recent = [];
  $scope.filter = filter;
  $scope.display_dates = [];
  $scope.user_items = {};
  $scope.items = [];
  $scope.datepicker_element;
  $scope.today = null;
  $scope.parse_statement = function(exp, initial_value) {
    var value = 0;

    exp = exp.replace(/\s*/, '');

    if (50 < exp.length) {
      value = initial_value;
      $scope.error = "Your entry was too long. Reverting your value."
    } else if (0 == exp.length) {
      value = 0;
    } else if (null == exp.match(/^[\d+-]+$/)) {
      value = initial_value;
      $scope.error = "Sorry, but we couldn't understand. Only +- and numbers are allowed. Reverting your value.";
    } else {
      angular.forEach(exp.match(/[+-]?\d+/g), function(stmt, i) {
        if ((0 == i) && (null != stmt.match(/[+-]/))) {
          value = initial_value;
        }

        value += parseInt(stmt, 10);
      });
    }

    return value;
  };
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
  $scope.change_current_date = function() {
    if (true == angular.isObject($scope.datepicker_element)) {
      var now = new Date();
      now.setHours(0,0,0,0);

      if (false == $scope.is_today(now)) {
        var currentSelectedDate = $scope.datepicker_element.datepicker("getDate");

        if (true == $scope.is_today(currentSelectedDate)) {
          $scope.change_date(1);
        }

        $scope.today = new Date(now);
      }
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
    $interval($scope.change_current_date, 1000*60*15);
    $scope.items = items;
  };
  $scope.get_recent = function() {
    recent_preference = new User();
    recent_preference.$get_preference({name:'recent'}, function(v){$scope.recent = v.data;},function(v){$scope.error = "Sorry, there was an issue getting your recent items.";});
  };
  $scope.get_user_item_data = function(item_id, d) {
    var date_data = $scope.user_items[d];
    var user_item_data;

    if (true == angular.isObject(date_data)) {
      user_item_data = $scope.filter(date_data, {item_id: parseInt(item_id)}, true)[0];
    } else {
      throw "No user item data for this date: " + d;
    }

    return user_item_data;
  };
  $scope.get_user_items = function(d) {
    $scope.user_items[d] = UserItem.query({date: d.getTime()});
  };
  $scope.selected_date = function() {
    return $scope.display_dates[1];
  };
  $scope.set_display_dates = function(selected_date) {
    if (null == $scope.today) {
      $scope.today = new Date(selected_date);
    }

    $scope.display_dates = [selected_date.ago(1), selected_date, selected_date.ago(-1)];
  };
  $scope.process_amount = function(expression, item_id, d) {
    var amount = -99;
    var user_item;

    $scope.clear_error();

    try {
      user_item = $scope.get_user_item_data(item_id, d);

      if (true == angular.isObject(user_item)) {
        var old_amt = user_item.amount;
        user_item.amount = $scope.parse_statement(expression, old_amt);
        user_item.$update({}, function(v){$scope.get_recent()}, function(v){user_item.amount = old_amt;$scope.error = "Sorry, there was an issue saving data.";});
      } else {
        user_item = new UserItem({amount: $scope.parse_statement(expression, 0), date: d, item_id: item_id});
        user_item.$save({}, function(v){$scope.user_items[d].push(user_item);$scope.get_recent()},function(v){$scope.error = "Sorry, there was an issue saving data.";});
      }
    } catch (e) {
      $scope.error = "Still loading data...";
    }
  };
  $scope.is_today = function(d) {
    if (true == angular.isObject($scope.today)) {
      return ($scope.today.getTime() == d.getTime());
    } else {
      return false;
    }
  };
  $scope.is_recent = function(item_type) {
    return (0 != $scope.filter($scope.recent, item_type, true).length);
  };
  /*
  $scope.test = function() {
    var tests = [];
    tests.push({expression:"1", outcome:1});
    tests.push({expression:"5000", outcome:5000});
    tests.push({expression:"50.38", outcome:88});
    tests.push({expression:"+10", outcome:17});
    tests.push({expression:"-11", outcome:-4});
    tests.push({expression:"1+9-8", outcome:2});
    tests.push({expression:"50+9-8", outcome:51});
    tests.push({expression:"+9-8", outcome:8});
    tests.push({expression:"-9-8", outcome:-10});
    tests.push({expression:"50-+-+-10+9--8++6", outcome:47});

    angular.forEach(tests, function(test, i) {
      var result = $scope.parse_statement(test.expression, 7);
      if (test.outcome != result) {
        throw "Test: '" + test.expression + "'\nExpected: '" + test.outcome + "'\nGot: '" + result + "'";
      }
    });
  };
  $scope.test();
  */
}]);
