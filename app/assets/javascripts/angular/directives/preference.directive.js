app.directive('streakalongNgPreference', ['$log', 'Preference', function(Logger, Preference) {
  function link(scope, element, attrs) {
    var preference = null;

    if (false == angular.isObject(scope.$parent.preferences)) {
      scope.$parent.preferences = new Preference();
    }

    if ((true !== scope.$parent.preferences.$resolved) && (true !== scope.$parent.preferencesLoading)) {
      scope.$parent.preferencesLoading = true;
      scope.$parent.preferences
      .$get()
      .then(
        function(v) {
          Logger.debug("Retrieved preferences '" + angular.toJson(scope.$parent.preferences) + "'.");
          scope.$parent.preferencesLoading = false;
        }
      ).catch(
        function(e){
          scope.$parent.error = "Sorry, there was an issue getting your preferences."
          Logger.error("Failure. '" + e + "'.");
        }
      );
    }

    scope.$watch(attrs.streakalongNgPreference, function (value) {
      preference = value;
    });

    element.click(function(e) {
      var preferences = scope.$parent.preferences;

      if (true == angular.isObject(preference)) {
        if (true == angular.isObject(preferences)) {
          preferences = _.extend(preferences, preference);
          preferences.$save().then(preferences.success).catch(preferences.failure);
        } else {
          Logger.error("preferences object from parent is invalid '" + preferences + "'.");
        }
      } else {
        Logger.warn("preference object is invalid, expecting an object got '" + preference + "'.");
      }
    });
  }

  return {
    scope: {},
    restrict: 'A',
    link: link
  };
}]);
