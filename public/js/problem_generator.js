// Generated by CoffeeScript 1.10.0
(function() {
  var Generator, genStruct, genType, root, typeToSize;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  typeToSize = {
    char: 1,
    short: 2,
    int: 4,
    long: 8
  };

  genType = function() {
    var index, type;
    index = Math.floor(Math.random() * 4);
    type = ['char', 'short', 'int', 'long'][index];
    return {
      type: type,
      size: typeToSize[type]
    };
  };

  genStruct = function() {
    var padding, structSize, type1, type2;
    type1 = genType();
    type2 = genType();
    padding = type1['type'] === type2['type'] ? 0 : type2['size'] - (type1['size'] % type2['size']);
    structSize = type1['size'] + padding + type2['size'];
    return {
      type: "struct {\n  " + type1['type'] + " a;\n  " + type2['type'] + " b;\n}",
      size: structSize
    };
  };

  root.Generator = Generator = (function() {
    function Generator() {}

    Generator.basic = function(struct) {
      var arrType, arraySize, b, code, genB, genE, genS, genSize, i;
      struct = struct != null ? struct : false;
      genB = function() {
        return 1 << Math.floor(Math.random() * 2 + 3);
      };
      genS = function() {
        return 1 << Math.floor(Math.random() * 2 + 2);
      };
      genE = function() {
        return 1;
      };
      genSize = function() {
        return 2 * (Math.floor(Math.random() * 16 + 5));
      };
      i = genSize();
      arrType = struct ? genStruct() : genType();
      arraySize = i * arrType['size'];
      b = genB();
      while (arraySize % b !== 0) {
        i = genSize();
        b = genB();
        arrType = struct ? genStruct() : genType();
        arraySize = arraySize = i * arrType['size'];
      }
      code = "";
      if (!struct) {
        code = arrType['type'] + " array[" + i + "];\n\nfor (int i = 0; i < " + i + "; ++i) {\n  array[i] = 10;\n}";
      } else {
        code = arrType['type'] + " array[" + i + "];\n\nfor (int i = 0; i < " + i + "; ++i) {\n  array[i].a = 10;\n  array[i].b = 10;\n}";
      }
      return {
        code: code,
        s: genS(),
        b: b,
        E: genE()
      };
    };

    Generator.easy = function(struct) {
      var arrType, arraySize, b, code, genB, genE, genS, genSize, i, index, j, loops;
      struct = struct != null ? struct : false;
      genB = function() {
        return 1 << Math.floor(Math.random() * 3 + 3);
      };
      genS = function() {
        return 1 << Math.floor(Math.random() * 3 + 2);
      };
      genE = function() {
        return Math.floor(Math.random() * 2 + 1);
      };
      genSize = function() {
        return 2 * (Math.floor(Math.random() * 9 + 2));
      };
      i = genSize();
      j = genSize();
      arrType = struct ? genStruct() : genType();
      arraySize = arrType['size'] * i * j;
      b = genB();
      while (arraySize % b !== 0) {
        i = genSize();
        j = genSize();
        b = genB();
        arrType = struct ? genStruct() : genType();
        arraySize = arrType['size'] * i * j;
      }
      loops = ["for (int i = 0; i < " + i + "; ++i)", "for (int j = 0; j < " + j + "; ++j)"];
      index = 1;
      code = "";
      if (!struct) {
        code = type + " array[" + i + "][" + j + "];\n\n" + loops[Math.abs(index - 1)] + " {\n  " + loops[index] + " {\n    array[i][j] = 15;\n  }\n}";
      } else {
        code = type + " array[" + i + "][" + j + "];\n\n" + loops[Math.abs(index - 1)] + " {\n  " + loops[index] + " {\n    array[i][j].a = 15;\n    array[i][j].b = 15;\n  }\n}";
      }
      return {
        code: code,
        s: genS(),
        b: b,
        E: genE()
      };
    };

    Generator.medium = function(struct) {
      var arrType, arraySize, b, code, genB, genE, genS, genSize, i, index, j, loops;
      genB = function() {
        return 1 << Math.floor(Math.random() * 3 + 3);
      };
      genS = function() {
        return 1 << Math.floor(Math.random() * 3 + 3);
      };
      genE = function() {
        return Math.floor(Math.random() * 4 + 1);
      };
      genSize = function() {
        return Math.floor(Math.random() * 16) + 15;
      };
      i = genSize();
      j = genSize();
      arrType = struct ? genStruct() : genType();
      arraySize = arrType['size'] * i * j;
      b = genB();
      while (arraySize % b !== 0) {
        i = genSize();
        j = genSize();
        b = genB();
        arrType = struct ? genStruct() : genType();
        arraySize = arrType['size'] * i * j;
      }
      loops = ["for (int i = 0; i < " + i + "; ++i)", "for (int j = 0; j < " + j + "; ++j)"];
      index = 0;
      code = "";
      if (!struct) {
        code = type + " array[" + i + "][" + j + "];\n\n" + loops[Math.abs(index - 1)] + " {\n  " + loops[index] + " {\n    array[i][j] = 15;\n  }\n}";
      } else {
        code = type + " array[" + i + "][" + j + "];\n\n" + loops[Math.abs(index - 1)] + " {\n  " + loops[index] + " {\n    array[i][j].a = 15;\n    array[i][j].b = 15;\n  }\n}";
      }
      return {
        code: code,
        s: genS(),
        b: b,
        E: genE()
      };
    };

    return Generator;

  })();

}).call(this);
