app.directive('streakalongNgUserPreference', ['User', function(User) {
  return function (scope, element, attrs) {
    scope.$watch(attrs.streakalongNgUserPreference, function (value) {
      element.click(function(e) {
        var user = new User();
        user.$set_preference(value);
      });
    });
  }
}]);
