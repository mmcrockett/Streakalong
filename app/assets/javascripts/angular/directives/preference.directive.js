app.directive('streakalongNgPreference', ['$log', 'Preference', function(Logger, Preference) {
  var link = function(scope, element, attrs) {
    var preference = null;

    var success = function(v) {
      Logger.debug("Retrieved preferences '" + angular.toJson(scope.$parent.preferences) + "'.");
      scope.$parent.preferencesLoading = false;
    };

    var failure = function(e) {
      scope.$parent.error = "Sorry, there was an issue getting your preferences."
      Logger.error("Failure. '" + e + "'.");
    };

    var save_preference = function() {
      var preferences = scope.$parent.preferences;
      var value       = scope.ngPreferenceValue;

      if (true == angular.isUndefined(value)) {
        value = scope.ngPreferenceModel;
      }

      Logger.debug("Trying to change preference '" + preference + "' to '" + value + "'.");

      if (true == angular.isString(preference)) {
        if (true == angular.isObject(preferences)) {
          preferences[preference] = value;
          preferences.$save().then(success).catch(failure);
        } else {
          Logger.error("preferences object from parent is invalid '" + preferences + "'.");
        }
      } else {
        Logger.warn("preference isn't valid, expecting a string, got '" + preference + "'.");
      }
    };

    if (false == angular.isObject(scope.$parent.preferences)) {
      scope.$parent.preferences = new Preference();
    }

    if ((true !== scope.$parent.preferences.$resolved) && (true !== scope.$parent.preferencesLoading)) {
      scope.$parent.preferencesLoading = true;
      scope.$parent.preferences
      .$get()
      .then(success)
      .catch(failure);
    }

    scope.$watch(attrs.streakalongNgPreference, function (name) {
      preference = name;
    });

    if (true == angular.isDefined(scope.ngPreferenceValue)) {
      element.click(save_preference);
    } else {
      element.change(save_preference);
    }
  };

  return {
    scope: {
      ngPreferenceModel: '=',
      ngPreferenceValue: '@',
    },
    restrict: 'A',
    link: link
  };
}]);
