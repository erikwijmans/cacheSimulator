// Generated by CoffeeScript 1.10.0
(function() {
  $(function() {
    var Manager, closer, manager;
    Manager = (function() {
      function Manager() {
        var div1, saved;
        div1 = $("<div class='trace'/>").appendTo('#content');
        this.cacheHome = $("<div class='cache'/>").appendTo($('#content'));
        this.logHome = $('<div class="panel-body"/>').appendTo($("<div class='panel panel-default'> <div class='panel-heading'> <h3 class='panel-title'>Trace</h3> </div> </div>").appendTo($("#content")));
        this.summaryHome = $('<div class="panel-body"/>').appendTo($("<div class='panel panel-default'> <div class='panel-heading'> <h3 class='panel-title'>Summary</h3> </div> </div>").appendTo($("#content")));
        $("<select class='selectpicker' data-width='fit' id='difficulty'> <optgroup label='Problem Difficulty'> <option>Basic</option> <option>Easy</option> <option>Medium</option> </optgroup> </select>").appendTo(div1);
        $("<button class='btn btn-primary' id='gen'>").text("Generate Random Problem").appendTo(div1).click((function(_this) {
          return function() {
            var difficulty, problem;
            difficulty = $("#difficulty").val().toLowerCase();
            console.log(difficulty);
            switch (difficulty) {
              case "basic":
                problem = Generator.basic();
                break;
              case "easy":
                problem = Generator.easy();
                break;
              case "medium":
                problem = Generator.medium();
                break;
              default:
                console.log("Unsupported type: " + difficulty);
            }
            _this.codeHome.val(problem.code);
            return _this.simManager.setParams(problem);
          };
        })(this));
        this.codeHome = $("<textarea class='form-control' rows='18' cols='50'/>").attr('placeholder', 'Code goes here').appendTo(div1).on('keydown', function(e) {
          var code, end, newText, self, start;
          self = $(this);
          if (e.which === 9 && (self.prop("selectionStart") != null)) {
            code = self.val();
            start = self.prop("selectionStart");
            end = self.prop("selectionEnd");
            newText = code.slice(0, start) + "  " + code.slice(end);
            self.val(newText);
            self.prop("selectionStart", start + 2);
            self.prop("selectionEnd", start + 2);
            return false;
          } else {
            return true;
          }
        });
        this.traceHome = $("<textarea class='form-control' rows='20' cols='50'/>").attr('placeholder', "Trace goes here (will be automatically filled if code is traced)");
        this.simulator = null;
        $("<button class='btn btn-primary'/>").text("Trace Code").appendTo(div1).click((function(_this) {
          return function() {
            var code;
            code = _this.codeHome.val();
            return getTrace(code, function(res) {
              var error, msg, t;
              error = res['error'];
              msg = res['msg'];
              if (!error) {
                return _this.traceHome.text(((function() {
                  var i, len, results;
                  results = [];
                  for (i = 0, len = msg.length; i < len; i++) {
                    t = msg[i];
                    results.push("0x" + t);
                  }
                  return results;
                })()).join("\n"));
              } else {
                return _this.traceHome.text("Syntax Error: \n" + msg);
              }
            });
          };
        })(this));
        this.traceHome.appendTo(div1);
        this.simbtn = $("<button class='btn btn-primary'/>").text("Simulate").appendTo(div1).click((function(_this) {
          return function() {
            var params, trace;
            if (_this.simbtn.hasClass("disabled")) {
              return;
            }
            trace = _this.traceHome.val().split("\n");
            params = _this.simManager.getParams();
            console.log(params);
            return getSim(trace, params, function(sim) {
              if (_this.simulator != null) {
                _this.simulator.destroy();
              }
              return _this.simulator = new CSim(params['s'], params['E'], sim, {
                parent: _this.cacheHome,
                log: _this.logHome,
                summary: _this.summaryHome
              });
            });
          };
        })(this));
        saved = Cookies.getJSON("cache_sim_save");
        console.log(saved);
        this.simManager = new SimManager(this.cacheHome, this.simbtn);
        if (saved != null) {
          this.codeHome.val(saved['code']);
          this.simManager.setParams(saved);
        } else {
          $("#gen").click();
        }
      }

      return Manager;

    })();
    manager = new Manager();
    closer = function() {
      var code, params;
      code = manager.codeHome.val();
      params = manager.simManager.getParams();
      params['code'] = code;
      params['s'] = 1 << params['s'];
      params['b'] = 1 << params['b'];
      Cookies.set("cache_sim_save", params, {
        expires: new Date(2020, 1, 1)
      });
      return true;
    };
    window.onunload = closer;
    return window.onbeforeunload = closer;
  });

}).call(this);
