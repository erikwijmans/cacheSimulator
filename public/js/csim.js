// Generated by CoffeeScript 1.10.0
(function() {
  var AccessType, CSim, STATUS, SimManager, height, nameMap, powOf2Checker, root, width,
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

  height = 50;

  width = 50;

  root.CSim = CSim = (function() {
    function CSim(s, E, res, options) {
      var _, accType, address, block, controlDiv, i, inner, j, k, l, len, line, newState, ref, ref1, ref2, ref3, row, set, state, tag;
      this.s = s;
      this.E = E;
      options = options != null ? options : {};
      this.parent = (ref = options['parent']) != null ? ref : $('body');
      this.log = options['log'];
      this.summary = options['summary'];
      this.numSets = 1 << this.s;
      this.currentIndex = 0;
      this.cache = [];
      this.out = [];
      this.states = [];
      this.missRati;
      this.intervalID = null;
      this.home = $("<div/>").appendTo(this.parent);
      if (this.summary != null) {
        this.summary.html("Summary <br/> Hits: " + res['hits'] + " <br/> Misses: " + res['misses'] + " <br/> Miss Ratio: " + res['miss_rate']);
      }
      controlDiv = $("<div class='row'/>").appendTo(this.home);
      $("<div class='col-md-4'/>").appendTo(controlDiv).append($("<button class='btn' id='autobtn'/>").attr("role", "start").text("Auto").click((function(_this) {
        return function() {
          var autoFunc;
          if ($("#autobtn").attr('role') === 'start') {
            autoFunc = function() {
              return _this.intervalID = setInterval(function() {
                _this.next();
                if (!_this.hasNext()) {
                  return clearInterval(_this.intervalID);
                }
              }, 1000);
            };
            autoFunc();
            return $("#autobtn").text("Stop").attr("role", 'stop');
          } else {
            clearInterval(_this.intervalID);
            return $("#autobtn").text("Auto").attr("role", 'start');
          }
        };
      })(this)));
      $("<div class='col-md-4'/>").appendTo(controlDiv).append($("<button class='btn'/>").text("Next").click((function(_this) {
        return function() {
          return _this.next();
        };
      })(this)));
      $("<div class='col-md-4'/>").appendTo(controlDiv).append($("<button class='btn'/>").text("Prev").click((function(_this) {
        return function() {
          return _this.prev();
        };
      })(this)));
      state = [];
      for (i = j = 0, ref1 = this.numSets; 0 <= ref1 ? j < ref1 : j > ref1; i = 0 <= ref1 ? ++j : --j) {
        row = $("<div class='row'/>").appendTo(this.home);
        $("<p class='col-md-2' style='margin-top: 15px;'> Set " + i + "</p>").appendTo(row);
        inner = $("<div class='row col-md-10'/>").appendTo(row);
        for (_ = k = 0, ref2 = this.E; 0 <= ref2 ? k < ref2 : k > ref2; _ = 0 <= ref2 ? ++k : --k) {
          block = $("<p class='block empty'/>").text('-1').appendTo($("<div class='col-md-3'/>").appendTo(inner));
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
          this.out.push("Address: 0x" + (address.toString(16)) + "  Tag: 0x" + (tag.toString(16)) + "  Set: " + set + "  " + nameMap[accType]);
        }
        newState = this.states[this.states.length - 1].slice(0);
        newState[block] = {
          tag: tag,
          type: accType
        };
        this.states.push(newState);
      }
    }

    CSim.prototype.print = function() {
      var b, i, j, len, ref, text;
      if (this.log != null) {
        text = (this.out.slice(1, +this.currentIndex + 1 || 9e9).join("<br><br>")) + "<br>";
        console.log(text);
        this.log.html(text);
        this.log.scrollTop(this.log[0].scrollHeight);
      }
      ref = this.states[this.currentIndex];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        b = ref[i];
        this.cache[i].removeClass("hit miss evict empty");
        this.cache[i].text(b.tag !== -1 ? "0x" + (b.tag.toString(16)) : b.tag);
        switch (b.type) {
          case 0:
            this.cache[i].addClass("empty");
            break;
          case AccessType.hit:
            this.cache[i].addClass("hit");
            break;
          case AccessType.miss:
            this.cache[i].addClass("miss");
            break;
          case AccessType.evict:
            this.cache[i].addClass("evict");
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
    powOf2: 0,
    nonPowOf2: 1,
    nan: 2
  });

  powOf2Checker = function(num) {
    if (isNaN(num)) {
      return STATUS.nan;
    } else {
      if ((num | (num - 1)) === (num + num - 1)) {
        return STATUS.powOf2;
      } else {
        return STATUS.nonPowOf2;
      }
    }
  };

  root.SimManager = SimManager = (function() {
    function SimManager(home, simbtn) {
      var inputDiv, nameDiv;
      this.home = home;
      this.simbtn = simbtn;
      nameDiv = $("<div class='row'/>").appendTo(this.home);
      $("<div class='col-md-3'/>").text("Number of Sets").appendTo(nameDiv);
      $("<div class='col-md-3'/>").text("Bytes per Block").appendTo(nameDiv);
      $("<div class='col-md-3'/>").text("Associativity").appendTo(nameDiv);
      $("<div class='col-md-3'/>").text("Memory Size").appendTo(nameDiv);
      inputDiv = $("<div class='row'/>").appendTo(this.home);
      this.checkDir = {};
      this.createCheckedInput('s', 1 << parseInt(Math.random() * 4 + 1), inputDiv);
      this.createCheckedInput('b', 1 << parseInt(Math.random() * 4 + 1), inputDiv);
      $("<div class='col-md-3'/>").appendTo(inputDiv).append($("<input type='number' id='E'/>").val(parseInt(Math.random() * 6 + 1)).attr("style", "width: 100%;"));
      $("<div class='col-md-3'/>").appendTo(inputDiv).append($("<input type='number' id='memSize'/>").val("64").attr("style", "width: 100%;"));
    }

    SimManager.prototype.getParams = function() {
      return {
        s: parseInt(Math.log($("#s").val()) / Math.log(2)),
        b: parseInt(Math.log($("#b").val()) / Math.log(2)),
        E: parseInt($("#E").val()),
        memSize: parseInt($("#memSize").val())
      };
    };

    SimManager.prototype.createCheckedInput = function(id, initialVal, parent) {
      $("<div class='col-md-3'/>").appendTo(parent).append($("<input type='number' id='" + id + "' data-toggle='tooltip' data-placement='auto' data-trigger='manual' />").tooltip().val(initialVal).attr("style", "width: 100%;").on('input', (function(_this) {
        return function() {
          return _this.checkInput(id);
        };
      })(this)));
      return this.checkDir[id] = true;
    };

    SimManager.prototype.checkInput = function(id) {
      var _, isAllTrue, ref, stat, val;
      val = parseInt($("#" + id).val());
      stat = powOf2Checker(val);
      switch (stat) {
        case STATUS.powOf2:
          $("#" + id).tooltip('hide');
          this.checkDir[id] = true;
          break;
        case STATUS.nonPowOf2:
          $("#" + id).attr('data-original-title', 'Must be a power of 2').tooltip('fixTitle').tooltip('show');
          this.checkDir[id] = false;
          break;
        case STATUS.nan:
          $("#" + id).attr('data-original-title', 'Must be a number').tooltip('fixTitle').tooltip('show');
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
