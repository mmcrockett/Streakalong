app.controller('SettingsController', [
'$scope',
'Settings',
'DateHelper',
'$log',
function(
  $scope,
  Settings,
  DateHelper,
  Logger
) {
  $scope.CM_TO_IN = _.constant(2.54);
  $scope.IN_IN_FT = _.constant(12);
  $scope.datepicker = {
    opened:false,
    show: function() {
      $scope.datepicker.opened = true;
    }
  };
  $scope.preferences = null;
  $scope.error  = "";
  $scope.height_ft = null;
  $scope.height_in = null;
  $scope.saving = false;
  $scope.set_imperial_height = function() {
    if (true == angular.isNumber($scope.settings.height)) {
      var inches = $scope.settings.height / $scope.CM_TO_IN();
      $scope.height_ft = Math.floor(inches / $scope.IN_IN_FT());
      $scope.height_in = Math.round(inches % $scope.IN_IN_FT());

      if ($scope.height_in == $scope.IN_IN_FT()) {
        $scope.height_ft += 1;
        $scope.height_in  = 0;
      }
    }
  };
  $scope.set_metric_height = function() {
    if (true == angular.isObject($scope.settings)) {
      $scope.settings.height = Math.round(($scope.height_ft * $scope.IN_IN_FT() + $scope.height_in) * $scope.CM_TO_IN());
    }
  };
  $scope.initialize = function(imperial_key) {
    $scope.IMPERIAL_KEY = _.constant(imperial_key);
    Settings
    .get({})
    .$promise
    .then(
      function(settings){
        $scope.settings = settings;
        $scope.birthday_to_date();
        $scope.set_imperial_height();
      }
    ).catch(
      function(e){
        $scope.error = "Couldn't load settings.";
        Logger.error("Failure '" + d + "' '" + e + "'.");
      }
    ).finally();
  };
  $scope.birthday_to_date = function() {
    if (true == angular.isString($scope.settings.birthday)) {
      $scope.settings.birthday = new Date($scope.settings.birthday);
    }
  };
  $scope.ignore_incomplete_settings = function() {
    if (true == angular.isDefined($scope.preferences.ignore_incomplete_settings)) {
      $scope.preferences.ignore_incomplete_settings = true;
      $scope.preferences.$save()
      .catch(
        function(e){
          $scope.error = "Couldn't save ignore-incomplete-settings.";
          Logger.error("Failure '" + e + "'.");
        });
    }

    return true;
  };
  $scope.save = function() {
    if ($scope.IMPERIAL_KEY() == $scope.preferences.units) {
      $scope.set_metric_height();
    }
    $scope.saving = true;
    $scope.settings
    .$save()
    .then(
      function(settings) {
        $scope.birthday_to_date();
      }
    ).catch(
      function(e){
        $scope.error = "Couldn't save settings.";
        Logger.error("Failure '" + e + "'.");
      }
    ).finally(function(){
      $scope.saving = false;
    });
  };
  $scope.clear_error = function() {
    $scope.error = "";
  };
}]);
