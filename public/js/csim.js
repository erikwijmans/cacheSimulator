// Generated by CoffeeScript 1.10.0
(function() {
  var AccessType, CSim, STATUS, SimManager, baseTime, maxVal, minVal, nameMap, powOf2Checker, range, root, scale,
    hasProp = {}.hasOwnProperty;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.AccessType = AccessType = Object.freeze({
    hit: 1,
    miss: 2,
    evict: 3
  });

  nameMap = {
    1: 'Hit',
    2: 'Miss',
    3: 'Evict'
  };

  baseTime = 2000;

  range = Math.exp(2);

  minVal = Math.log(baseTime / range);

  maxVal = Math.log(baseTime * range);

  scale = maxVal - minVal;

  performance.now = performance.now || date.now;

  root.CSim = CSim = (function() {
    function CSim(params1, res, options) {
      var _, accType, address, block, btnHome, controlDiv, i, inner, j, k, l, len, line, newState, ref, ref1, ref2, ref3, row, set, sliderHome, state, tag;
      this.params = params1;
      options = options != null ? options : {};
      this.parent = (ref = options['parent']) != null ? ref : $('body');
      this.log = options['log'];
      this.summary = options['summary'];
      this.numSets = 1 << this.params.s;
      this.currentIndex = 0;
      this.cache = [];
      this.out = [];
      this.states = [];
      this.missRati;
      this.intervalID = null;
      this.home = $("<div/>").appendTo(this.parent);
      if (this.summary != null) {
        this.summary.html("Hits: " + res['hits'] + " <br/> Misses: " + res['misses'] + " <br/> Evicts: " + res['evicts'] + " <br/> Miss Ratio: " + res['miss_rate']);
      }
      $("<div class='row'> <hr> <h1 class='panel-title'>Simulation Controls</h1> <br/> </div>").appendTo(this.home);
      controlDiv = $("<div class='btn-group row'/>").appendTo(this.home);
      btnHome = $("<div class='col-sm-7'/>").appendTo(controlDiv);
      $("<button class='btn btn-primary' id='autobtn' data-toggle='tooltip' data-title='Automatically advanced the simulation. Use the slider to control speed' data-placement='auto' />").attr("role", "play").text("Play").tooltip({
        'delay': {
          show: 1000,
          hide: 100
        }
      }).appendTo(btnHome).click((function(_this) {
        return function() {
          var autoFunc, self;
          self = $("#autobtn");
          if (self.attr('role') === 'play') {
            _this.lastTime = 0;
            autoFunc = function() {
              return _this.intervalID = setInterval(function() {
                var sliderval, time;
                sliderval = _this.slider.slider("getValue");
                time = Math.exp(minVal + sliderval * scale);
                if ((performance.now() - _this.lastTime) > time) {
                  _this.lastTime = performance.now();
                  return _this.next();
                } else if (!_this.hasNext()) {
                  clearInterval(_this.intervalID);
                  return self.text("Play").attr("role", "play");
                }
              }, 2);
            };
            autoFunc();
            return self.text("Pause").attr("role", 'pause');
          } else {
            clearInterval(_this.intervalID);
            return self.text("Play").attr("role", 'play');
          }
        };
      })(this));
      $("<button class='btn btn-primary' data-toggle='tooltip' data-title='Moves the simulation back one memory accesses' data-placement='auto' />").text("Prev").appendTo(btnHome).tooltip({
        'delay': {
          show: 1000,
          hide: 100
        }
      }).click((function(_this) {
        return function() {
          return _this.prev();
        };
      })(this));
      $("<button class='btn btn-primary' data-toggle='tooltip' data-title='Moves the simulation forward one memory accesses' data-placement='auto' />").text("Next").appendTo(btnHome).tooltip({
        'delay': {
          show: 1000,
          hide: 100
        }
      }).click((function(_this) {
        return function() {
          return _this.next();
        };
      })(this));
      $("<button class='btn btn-primary' data-toggle='tooltip' data-title='Resets the simulation back to accesses 0' data-placement='auto' />").text("Reset").appendTo(btnHome).tooltip({
        'delay': {
          show: 1000,
          hide: 100
        }
      }).click((function(_this) {
        return function() {
          _this.currentIndex = 0;
          return _this.print();
        };
      })(this));
      sliderHome = $("<div class='col-sm-5'/>").appendTo(controlDiv);
      $("<label>Speed</label>").appendTo(sliderHome);
      this.slider = $("<input type='text' name='somename' data-provide='slider' data-slider-min='0' data-slider-max='1' data-slider-step='0.001' data-slider-value='0.5' data-slider-tooltip='show' />").appendTo(sliderHome).slider();
      $("<div class='row'/>").appendTo(this.home).append($("<hr><h1 class='panel-title'>Cache</h1><br/>"));
      state = [];
      for (i = j = 0, ref1 = this.numSets; 0 <= ref1 ? j < ref1 : j > ref1; i = 0 <= ref1 ? ++j : --j) {
        row = $("<div class='row panel-group'/>").appendTo(this.home);
        $("<p class='col-sm-2' style='margin-top: 15px;'> Set " + i + " </p>").appendTo(row);
        inner = $("<div class='row col-sm-10'/>").appendTo(row);
        for (_ = k = 0, ref2 = this.params.E; 0 <= ref2 ? k < ref2 : k > ref2; _ = 0 <= ref2 ? ++k : --k) {
          block = $("<div class='col-sm-3'> <div class='panel panel-default empty'> <div class='panel-body'/> </div> </div>").appendTo(inner).find($(".panel-body")).text("Empty");
          this.cache.push(block);
          state.push({
            tag: -1,
            type: 0
          });
        }
      }
      this.states.push(state);
      this.out.push("");
      ref3 = res['trace'];
      for (l = 0, len = ref3.length; l < len; l++) {
        line = ref3[l];
        block = line['block'];
        tag = line['tag'];
        accType = line['acc_type'];
        address = line['address'];
        set = line['set'];
        if (this.log != null) {
          this.out.push(("<strong>Address:</strong> 0x" + (address.toString(16)) + "\n<strong>Tag:</strong> 0x" + (tag.toString(16)) + " <strong>Set:</strong> " + set + "\n<strong>" + nameMap[accType] + "</strong>").split("\n").join("<br/>"));
        }
        newState = this.states[this.states.length - 1].slice(0);
        newState[block] = {
          tag: tag,
          type: accType,
          address: address
        };
        this.states.push(newState);
        this.blockSize = 1 << this.params.b;
      }
    }

    CSim.prototype.print = function() {
      var b, i, j, len, ref, text;
      if (this.log != null) {
        text = (this.out.slice(1, +this.currentIndex + 1 || 9e9).join("<br><br>")) + "<br>";
        this.log.html(text);
        this.log.scrollTop(this.log[0].scrollHeight);
      }
      ref = this.states[this.currentIndex];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        b = ref[i];
        this.cache[i].parent().removeClass("hit miss evict empty");
        this.cache[i].text(b.tag !== -1 ? "0x" + (b.address.toString(16)) + " to 0x" + ((b.address + this.blockSize - 1).toString(16)) : "Empty");
        switch (b.type) {
          case 0:
            this.cache[i].parent().addClass("empty");
            break;
          case AccessType.hit:
            this.cache[i].parent().addClass("hit");
            break;
          case AccessType.miss:
            this.cache[i].parent().addClass("miss");
            break;
          case AccessType.evict:
            this.cache[i].parent().addClass("evict");
            break;
          default:
            console.log("Unsupported Type: " + b.type);
        }
      }
      return true;
    };

    CSim.prototype.next = function() {
      if (this.hasNext()) {
        ++this.currentIndex;
        this.print();
        return true;
      } else {
        return false;
      }
    };

    CSim.prototype.prev = function() {
      if (this.hasPrev()) {
        --this.currentIndex;
        this.print();
        return true;
      } else {
        return false;
      }
    };

    CSim.prototype.hasNext = function() {
      return this.currentIndex + 1 < this.states.length;
    };

    CSim.prototype.hasPrev = function() {
      return this.currentIndex > 0;
    };

    CSim.prototype.destroy = function() {
      this.home.remove();
      if (this.log != null) {
        this.log.text("");
      }
      return clearInterval(this.intervalID);
    };

    return CSim;

  })();

  STATUS = Object.freeze({
    OK: 0,
    nonPowOf2: 1,
    nan: 2
  });

  powOf2Checker = function(num) {
    if (isNaN(num) || num === 0) {
      return STATUS.nan;
    } else {
      if ((num | (num - 1)) === (num + num - 1)) {
        return STATUS.OK;
      } else {
        return STATUS.nonPowOf2;
      }
    }
  };

  root.SimManager = SimManager = (function() {
    function SimManager(home, simbtn, params) {
      var inputDiv, nameDiv;
      this.home = home;
      this.simbtn = simbtn;
      $("<div class='row'> <h1 class='panel-title'>Cache Settings</h1> </div> <br/>").appendTo(this.home);
      nameDiv = $("<div class='row'/>").appendTo(this.home);
      $("<h3 class='col-sm-3 panel-title'/>").text("Number of Sets").appendTo(nameDiv);
      $("<h3 class='col-sm-3 panel-title'/>").text("Bytes per Block").appendTo(nameDiv);
      $("<h3 class='col-sm-3 panel-title'/>").text("Associativity").appendTo(nameDiv);
      $("<h3 class='col-sm-3 panel-title'/>").text("Memory Size").appendTo(nameDiv);
      inputDiv = $("<div class='row'/>").appendTo(this.home);
      params = params != null ? params : {};
      this.checkDir = {};
      this.createCheckedInput('s', params['s'], inputDiv, powOf2Checker);
      this.createCheckedInput('b', params['b'], inputDiv, powOf2Checker);
      this.createCheckedInput('E', params['E'], inputDiv, function(val) {
        if (isNaN(val) || val === 0) {
          return STATUS.nan;
        } else {
          return STATUS.OK;
        }
      });
      $("<div class='col-sm-3'/>").appendTo(inputDiv).append($("<input type='text' id='memSize'/>").val("64").attr("style", "width: 100%;"));
    }

    SimManager.prototype.getParams = function() {
      return {
        s: parseInt(Math.log($("#s").val()) / Math.log(2)),
        b: parseInt(Math.log($("#b").val()) / Math.log(2)),
        E: parseInt($("#E").val()),
        memSize: parseInt($("#memSize").val())
      };
    };

    SimManager.prototype.setParams = function(p) {
      $("#s").val(p.s).trigger("change");
      $("#b").val(p.b).trigger("change");
      return $("#E").val(p.E).trigger("change");
    };

    SimManager.prototype.createCheckedInput = function(id, initialVal, parent, checker) {
      return $("<div class='col-sm-3'/>").appendTo(parent).append($("<input type='text' id='" + id + "' data-toggle='tooltip' data-placement='auto' data-trigger='manual' />").tooltip().val(initialVal).attr("style", "width: 100%;").on('input change', (function(_this) {
        return function() {
          return _this.checkInput(id, checker);
        };
      })(this)).trigger("change"));
    };

    SimManager.prototype.checkInput = function(id, checker) {
      var _, isAllTrue, ref, self, stat, val;
      val = parseInt($("#" + id).val());
      stat = checker(val);
      self = $("#" + id);
      switch (stat) {
        case STATUS.OK:
          $("#" + id).tooltip('hide');
          this.checkDir[id] = true;
          break;
        case STATUS.nonPowOf2:
          if (self.attr('data-original-title') !== 'Must be a power of 2') {
            self.attr('data-original-title', 'Must be a power of 2').tooltip('fixTitle').tooltip('show');
          }
          this.checkDir[id] = false;
          break;
        case STATUS.nan:
          if (self.attr('data-original-title') !== 'Must be a non-zero number') {
            self.attr('data-original-title', 'Must be a non-zero number').tooltip('fixTitle').tooltip('show');
          }
          this.checkDir[id] = false;
          break;
        default:
          console.log("STATUS of " + stat + " is unsupported");
      }
      isAllTrue = true;
      ref = this.checkDir;
      for (_ in ref) {
        if (!hasProp.call(ref, _)) continue;
        val = ref[_];
        if (!val) {
          isAllTrue = false;
          break;
        }
      }
      if (isAllTrue) {
        return this.simbtn.removeClass('disabled');
      } else {
        return this.simbtn.addClass('disabled');
      }
    };

    return SimManager;

  })();

}).call(this);
