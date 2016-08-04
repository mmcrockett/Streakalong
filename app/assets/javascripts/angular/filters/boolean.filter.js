app.filter('boolean', function() {
  return function(input, boolean_translation) {
    if (true === input) {
      if (true == _.isArray(boolean_translation)) {
        return _.first(boolean_translation);
      } else {
        return true;
      }
    } else {
      if (true == _.isArray(boolean_translation)) {
        return _.last(boolean_translation);
      } else {
        return false;
      }
    }
  };
})
