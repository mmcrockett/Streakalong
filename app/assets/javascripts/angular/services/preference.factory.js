app.factory('Preference', ['$resource', '$log', function($resource, Logger) {
  var Preference = $resource('/preferences.json', {}, {});

  Preference.prototype.add_recent = function(item_id) {
    if (false == angular.isNumber(item_id)) {
      Logger.warn("Item id not a number '" + item_id + "'.");
    } else {
      this.recent_dirty = true;
      this.recent = _.without(this.recent, item_id);

      this.recent.push(item_id);

      while (16 < this.recent.length) {
        this.recent.shift();
      }
    }
  };

  Preference.prototype.save_recent = function() {
    if (true == this.recent_dirty) {
      this.$save().then(this.success).catch(this.failure);
    }
  };

  Preference.prototype.success = function(v) {
    Logger.debug("Saved preferences '" + angular.toJson(v) + "'.");
    this.recent_dirty = false;
  };

  Preference.prototype.failure = function (e) {
    Logger.error("Failure saving preference '" + e + "'.");
  };

  return Preference;
}]);
