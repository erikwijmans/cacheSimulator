// Generated by CoffeeScript 1.10.0
(function() {
  var ajaxReq, code, getSim, getTrace, hostname, parser, root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  code = "int main() {\nstruct pixel_t{\n    unsigned char r;\n    unsigned char g;\n    unsigned char b;\n    unsigned char a;\n};\n\nstruct pixel_t pixel[16][16];\nregister int i, j;\nint x;\nfor (i = 0; i < 16; i ++){\n    for (j = 0; j < 16; j ++){\n        x = pixel[j][i].r;\n        pixel[j][i].g = 0;\n        pixel[j][i].b = 0;\n        pixel[j][i].a = 0;\n} }\n}";

  parser = $("<a/>");

  parser.href = window.url;

  hostname = parser.hostname;

  if (hostname.find("github.io") !== 0) {
    hostname = "ec2-52-43-229-235.us-west-2.compute.amazonaws.com";
  }

  ajaxReq = function(url, data, cb) {
    return $.ajax({
      dataType: 'json',
      contentType: 'application/json; charset=UTF-8',
      type: "POST",
      url: url,
      data: data,
      success: cb,
      error: function(err) {
        return console.log(err);
      }
    });
  };

  root.getTrace = getTrace = function(code, cb) {
    return ajaxReq(hostname + "/trace", JSON.stringify(code), cb);
  };

  root.getSim = getSim = function(trace, cacheParams, cb) {
    return ajaxReq(hostname + "/simulate", JSON.stringify({
      trace: trace,
      s: cacheParams['s'],
      b: cacheParams['b'],
      E: cacheParams['E'],
      memSize: cacheParams['memSize']
    }), cb);
  };

  (function() {
    return getTrace(code, function(res) {
      return getSim(res, {
        s: 3,
        b: 3,
        E: 3,
        memSize: 64
      }, function(res) {
        return console.log(res);
      });
    });
  });

}).call(this);
