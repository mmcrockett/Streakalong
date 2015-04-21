app.controller('CalendarController', ['$scope', '$http', '$interval', '$timeout', 'UserItem', 'User', 'filterFilter', function($scope, $http, $interval, $timeout, UserItem, User, filter) {
  $scope.thinking = 0;
  var user_item_success = function(response) {
    $scope.thinking -= 1;
    $scope.get_recent();
  };
  var user_item_failure = function(response) {
    response.config.data.amount = response.config.data.previous_amount;
    response.config.data.previous_amount = undefined;
    response.config.data.error = true;
    console.error(response.config.data)
    $scope.error = "Sorry, there was an issue saving data for '" + $scope.items[response.config.data.item_id] + "'.";
    $scope.thinking -= 1;
  };
  $scope.save_items = function() {
    angular.forEach($scope.user_items, function(obj, d) {
      angular.forEach($scope.filter(obj, {previous_amount: '!!'}), function(user_item, i) {
        $scope.thinking += 1;
        if (true == angular.isNumber(user_item.id)) {
          user_item.$update({}, user_item_success, user_item_failure);
        } else {
          user_item.$save({}, user_item_success, user_item_failure);
        }
      });
    });
  };
  timeout = null;
  $scope.debounce_save_items = function() {
    if (timeout) {
      $timeout.cancel(timeout);
    }
    timeout = $timeout($scope.save_items, 2500);
  };
  $scope.error  = "";
  $scope.recent = [];
  $scope.filter = filter;
  $scope.display_dates = [];
  $scope.user_items = {};
  $scope.dirty_user_item = 0;
  $scope.items = [];
  $scope.datepicker_element;
  $scope.today = null;
  $scope.$watch('dirty_user_item', $scope.debounce_save_items);
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
      user_item_data = $scope.filter(date_data, {item_id: parseInt(item_id)})[0];
    } else {
      throw "No user item data for this date: " + d;
    }

    return user_item_data;
  };
  $scope.get_user_items = function(d) {
    UserItem.query({date: d.getTime()}, function(v){$scope.user_items[d] = v;}, function(e){$scope.error = "Couldn't load data.";});
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
    if (0 == $scope.thinking) {
      var amount = -99;
      var user_item;

      $scope.clear_error();

      try {
        user_item = $scope.get_user_item_data(item_id, d);

        if (false == angular.isObject(user_item)) {
          user_item = new UserItem({amount: 0, date: d, item_id: item_id});
          $scope.user_items[d].push(user_item);
        }

        if (false == angular.isNumber(user_item.previous_amount)) {
          user_item.previous_amount = user_item.amount;
        }

        user_item.amount = $scope.parse_statement(expression, user_item.amount);

        if (user_item.previous_amount === user_item.amount) {
          user_item.previous_amount = undefined;
        }

        $scope.dirty_user_item += 1;
      } catch (e) {
        $scope.error = "Still loading data...";
      }
    } else {
      $scope.error = "Busy saving data...";
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
