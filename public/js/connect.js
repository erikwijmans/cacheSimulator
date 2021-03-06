// Generated by CoffeeScript 1.10.0
(function() {
  var ajaxReq, baseURL, getSim, getTrace, root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  baseURL = "http://ec2-52-10-240-194.us-west-2.compute.amazonaws.com";

  ajaxReq = function(url, data, cb) {
    return $.ajax({
      dataType: 'text',
      contentType: 'text/plain',
      type: "POST",
      url: "" + baseURL + url,
      data: data,
      success: function(data) {
        return cb(JSON.parse(data));
      },
      error: function(err) {
        return console.log(err);
      }
    });
  };

  root.getTrace = getTrace = function(code, cb) {
    return ajaxReq("/trace", JSON.stringify(code), cb);
  };

  root.getSim = getSim = function(trace, cacheParams, style, cb) {
    return ajaxReq("/simulate", JSON.stringify({
      trace: trace,
      s: cacheParams['s'],
      b: cacheParams['b'],
      E: cacheParams['E'],
      memSize: cacheParams['memSize'],
      style: style
    }), cb);
  };

}).call(this);
