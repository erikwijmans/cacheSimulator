// Generated by CoffeeScript 1.10.0
(function() {
  var AccessType, CSim, data, height, nameMap, root, sim, simFunc, width;

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
    function CSim(s1, E, res, options) {
      var _, accType, address, block, i, inner, j, k, l, len, line, newState, ref, ref1, ref2, ref3, row, s, set, state, tag;
      this.s = s1;
      this.E = E;
      options = options != null ? options : {};
      this.parent = (ref = options['parent']) != null ? ref : $('body');
      this.log = options['log'];
      this.numSets = 1 << this.s;
      this.currentIndex = 0;
      this.cache = [];
      this.out = [];
      this.states = [];
      this.hits = res['hits'];
      this.misses = res['misses'];
      state = [];
      for (i = j = 0, ref1 = this.numSets; 0 <= ref1 ? j < ref1 : j > ref1; i = 0 <= ref1 ? ++j : --j) {
        row = $("<div class='row'/>").appendTo(this.parent);
        $("<p class='col-md-2' style='margin-top: 15px;'> Set " + i + "</p>").appendTo(row);
        inner = $("<div class='row col-md-10'/>").appendTo(row);
        for (_ = k = 0, ref2 = this.E; 0 <= ref2 ? k < ref2 : k > ref2; _ = 0 <= ref2 ? ++k : --k) {
          block = $("<p class='block'/>").text('-1').appendTo($("<div class='col-md-3'/>").appendTo(inner));
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
        console.log(line);
        block = line['block'];
        tag = line['tag'];
        accType = line['acc_type'];
        address = line['address'];
        set = line['set'];
        if (this.log != null) {
          this.out.push("Address: 0x" + (address.toString(16)) + "  Tag: 0x" + (tag.toString(16)) + "  Set: " + set + "  " + nameMap[accType]);
        }
        newState = (function() {
          var len1, m, ref4, results;
          ref4 = this.states[this.states.length - 1];
          results = [];
          for (m = 0, len1 = ref4.length; m < len1; m++) {
            s = ref4[m];
            results.push(s);
          }
          return results;
        }).call(this);
        newState[block] = {
          tag: tag,
          type: accType
        };
        this.states.push(newState);
      }
    }

    CSim.prototype.print = function() {
      var b, i, j, len, ref;
      if (this.log != null) {
        this.log.html("<br>" + (this.out.slice(0, +this.currentIndex + 1 || 9e9).reverse().join("<br><br>")));
      }
      ref = this.states[this.currentIndex];
      for (i = j = 0, len = ref.length; j < len; i = ++j) {
        b = ref[i];
        this.cache[i].removeClass("hit miss evict");
        this.cache[i].text(b.tag !== -1 ? "0x" + (b.tag.toString(16)) : b.tag);
        switch (b.type) {
          case 0:
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
      if (this.hashPrev()) {
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
      return this.currentIndex >= 0;
    };

    return CSim;

  })();

  data = JSON.parse('{"misses": 20, "trace": [{"acc_type": 2, "tag": 32, "address": 4164, "block": 204, "set": 17}, {"acc_type": 2, "tag": 0, "address": 0, "block": 0, "set": 0}, {"acc_type": 2, "tag": 32, "address": 4160, "block": 192, "set": 16}, {"acc_type": 2, "tag": 0, "address": 8, "block": 24, "set": 2}, {"acc_type": 2, "tag": 35, "address": 4564, "block": 252, "set": 21}, {"acc_type": 2, "tag": 6, "address": 800, "block": 96, "set": 8}, {"acc_type": 2, "tag": 35, "address": 4560, "block": 240, "set": 20}, {"acc_type": 2, "tag": 6, "address": 808, "block": 120, "set": 10}, {"acc_type": 2, "tag": 38, "address": 4964, "block": 300, "set": 25}, {"acc_type": 2, "tag": 12, "address": 1600, "block": 193, "set": 16}, {"acc_type": 2, "tag": 38, "address": 4960, "block": 288, "set": 24}, {"acc_type": 2, "tag": 12, "address": 1608, "block": 216, "set": 18}, {"acc_type": 2, "tag": 41, "address": 5364, "block": 348, "set": 29}, {"acc_type": 2, "tag": 18, "address": 2400, "block": 289, "set": 24}, {"acc_type": 2, "tag": 41, "address": 5360, "block": 336, "set": 28}, {"acc_type": 2, "tag": 18, "address": 2408, "block": 312, "set": 26}, {"acc_type": 2, "tag": 45, "address": 5764, "block": 12, "set": 1}, {"acc_type": 2, "tag": 25, "address": 3200, "block": 1, "set": 0}, {"acc_type": 2, "tag": 45, "address": 5760, "block": 2, "set": 0}, {"acc_type": 2, "tag": 25, "address": 3208, "block": 25, "set": 2}], "hits": 0}');

  sim = new CSim(5, 12, data, {
    parent: $("<div class='container cache'/>").appendTo($('#content')),
    log: $('<p class="log"/>').appendTo($('#content'))
  });

  simFunc = function() {
    if (sim.hasNext()) {
      sim.next();
      return setTimeout(simFunc, 1000);
    }
  };

  simFunc();

}).call(this);
