app.factory('Activity', ['$resource', function($resource) {
  var activity = $resource('/activities.json', {}, {});
  activity.prototype.queue_id = function() {
    var id = this.item_id + '_';

    if (true == angular.isDate(this.date)) {
      id += this.date.format('Y-m-d');
    } else {
      id += this.date;
    }

    return id;
  };

  return activity;
}]);
