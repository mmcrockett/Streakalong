app.controller('ActivitiesController', [
'$scope',
'$timeout',
'Activity',
'Calories',
'Item',
'DateHelper',
'filterFilter',
'$log',
function(
  $scope,
  $timeout,
  Activity,
  Calories,
  Item,
  DateHelper,
  filter,
  Logger
) {
  $scope.INVALID_STATEMENT  = _.constant("Sorry, but we couldn't understand. Only +- and numbers are allowed. Reverting your value.");
  $scope.TOO_LONG_STATEMENT = _.constant("Your entry was too long. Reverting your value.");
  $scope.MAX_STATEMENT_SIZE = _.constant(50);

  $scope.date_helper = new DateHelper();
  $scope.$watch('date_helper.selectedDate', $scope.date_helper.set_display_dates);

  $scope.thinking = 0;
  $scope.preferences = null;
  $scope.activity_success = function(response) {
    $scope.process_queue_item(response);
  };
  $scope.activity_failure = function(response) {
    var activity = response.config.data;
    activity.amount = activity.previous_amount;
    activity.previous_amount = undefined;
    activity.error = true;
    Logger.error(activity)
    $scope.error = "Sorry, there was an issue saving data for '" + $scope.find_item(activity.item_id).name + "' on '" + activity.date + "'.";
  };
  $scope.calories = function(d) {
    var base_value = $scope.calorie_base[d];
    var date_data  = $scope.activities[d];
    var value      = null;

    if (true == angular.isNumber(base_value)) {
      value = base_value;

      angular.forEach(date_data, function(activity, i) {
        var item_data = $scope.find_item(activity.item_id);

        if (true == angular.isObject(item_data)) {
          value += activity.amount * item_data.kcal;
        }
      })
    }

    return value;
  };
  $scope.initialize = function() {
    Item
    .query({})
    .$promise
    .then(
      function(items){
        $scope.items = items;
      }
    ).catch(
      function(e){
        $scope.error = "Couldn't load items.";
        Logger.error("Failure '" + d + "' '" + e + "'.");
      }
    ).finally();
  };
  $scope.find_item = function(id) {
    return _.findWhere($scope.items, {id:id});
  };
  $scope.save_items = function() {
    angular.forEach($scope.activities, function(obj, d) {
      angular.forEach($scope.filter(obj, {previous_amount: '!!'}), function(activity, i) {
        $scope.thinking += 1;
        $scope.preferences.save_recent();
        activity.$save().then($scope.activity_success).catch($scope.activity_failure).finally(function(){$scope.thinking -= 1;});
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
  $scope.calorie_base = {};
  $scope.dirty_activity = 0;
  $scope.items = [];
  $scope.$watch('dirty_activity', $scope.debounce_save_items);
  $scope.parse_statement = function(exp, initial_value) {
    var value = 0;

    exp = exp.replace(/\s*/, '');

    if ($scope.MAX_STATEMENT_SIZE() < exp.length) {
      value = initial_value;
      $scope.error = $scope.TOO_LONG_STATEMENT();
    } else if (0 == exp.length) {
      value = 0;
    } else if (null == exp.match(/^[\d.+-]+$/)) {
      value = initial_value;
      $scope.error = $scope.INVALID_STATEMENT();
    } else {
      angular.forEach(exp.match(/[+-]?[\d.]+/g), function(stmt, i) {
        if ((0 == i) && (null != stmt.match(/[+-]/))) {
          value = initial_value;
        }

        value += parseFloat(stmt);
      });
    }

    return Math.round(value);
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
    Calories
    .get({date: d.getTime()})
    .$promise
    .then(
      function(calorie_data){
        $scope.calorie_base[d] = calorie_data.kcalest;
      }
    ).catch(
      function(e){
        $scope.error = "Couldn't load calorie data.";
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

    if (true == angular.isObject($scope.preferences)) {
      $scope.preferences.add_recent(item_id);
    } else {
      Logger.warn('preferences object is not initialized.');
    }

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
}]);
