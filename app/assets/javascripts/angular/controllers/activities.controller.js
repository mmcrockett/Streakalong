app.controller('ActivitiesController', [
'$scope',
'$http',
'$timeout',
'Activity',
'DateHelper',
'filterFilter',
'$log',
function(
  $scope,
  $http,
  $timeout,
  Activity,
  DateHelper,
  filter,
  Logger
) {
  $scope.date_helper = new DateHelper();
  $scope.$watch('date_helper.selectedDate', $scope.date_helper.set_display_dates);

  $scope.thinking = 0;
  $scope.preferences = null;
  $scope.activity_success = function(response) {
    $scope.thinking -= 1;
    $scope.process_queue_item(response);
  };
  $scope.activity_failure = function(response) {
    response.config.data.amount = response.config.data.previous_amount;
    response.config.data.previous_amount = undefined;
    response.config.data.error = true;
    Logger.error(response.config.data)
    $scope.error = "Sorry, there was an issue saving data for '" + $scope.items[response.config.data.item_id] + "'.";
    $scope.thinking -= 1;
  };
  $scope.initialize = function(items) {
    $scope.setup_items(items);
  };
  $scope.save_items = function() {
    angular.forEach($scope.activities, function(obj, d) {
      angular.forEach($scope.filter(obj, {previous_amount: '!!'}), function(activity, i) {
        $scope.thinking += 1;
        $scope.preferences.save_recent();
        activity.$save().then($scope.activity_success).catch($scope.activity_failure);
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
  $scope.expression_queue = {};
  $scope.filter = filter;
  $scope.activities = {};
  $scope.dirty_activity = 0;
  $scope.items = [];
  $scope.$watch('dirty_activity', $scope.debounce_save_items);
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
  $scope.get_activity = function(item_id, d) {
    if (true == angular.isString(d)) {
      d = new Date(Date.parse(d));
      d = d.ago(-d.getTimezoneOffset()/60/24);
    }

    var date_data = $scope.activities[d];
    var activity;

    if (true == angular.isObject(date_data)) {
      activity = $scope.filter(date_data, {item_id: parseInt(item_id)}, true)[0];
    } else {
      throw "No activity data for '" + item_id + "' on '" + d + "'.";
    }

    return activity;
  };
  $scope.load_activities = function(d) {
    Activity
    .query({date: d.getTime()})
    .$promise
    .then(
      function(activities){
        $scope.activities[d] = activities;
      }
    ).catch(
      function(e){
        $scope.error = "Couldn't load data.";
        Logger.error("Failure '" + d + "' '" + e + "'.");
      }
    ).finally();
  };
  $scope.queue_expression = function(activity, expression) {
    Logger.debug("Queueing expression '" + expression + "'.");
    if (false == angular.isObject($scope.expression_queue[activity])) {
      $scope.expression_queue[activity] = [];
    }

    $scope.expression_queue[activity].push(expression);
  };
  $scope.process_queue_item = function(activity) {
    var expressions = $scope.expression_queue[activity];

    if (true == angular.isObject(expressions)) {
      angular.forEach(expressions, function(exp, i) {
        $scope.process_amount(exp, activity.item_id, activity.date);
        $scope.dirty_activity += 1;
      });

      $scope.expression_queue[activity] = [];
    }
  };
  $scope.process_amount = function(expression, item_id, d) {
    var amount = -99;
    var activity;

    item_id = parseInt(item_id);

    $scope.preferences.add_recent(item_id);

    $scope.clear_error();

    try {
      activity = $scope.get_activity(item_id, d);

      if (false == angular.isObject(activity)) {
        activity = new Activity({amount: 0, date: d, item_id: item_id});
        $scope.activities[d].push(activity);
      }

      if (false == angular.isNumber(activity.previous_amount)) {
        activity.previous_amount = activity.amount;
      }

      activity.amount = $scope.parse_statement(expression, activity.amount);

      if (activity.previous_amount === activity.amount) {
        activity.previous_amount = undefined;
      }

      if (0 == $scope.thinking) {
        $scope.dirty_activity += 1;
      } else {
        $scope.queue_expression(activity, expression);
      }
    } catch (e) {
      $scope.error = "Still loading data...";
    }
  };
  $scope.is_recent = function(item_type) {
    if (true == angular.isArray($scope.preferences.recent)) {
      return (0 != $scope.filter($scope.preferences.recent, item_type, true).length);
    } else {
      return false;
    }
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
