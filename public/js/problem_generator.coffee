root = exports ? this

typeToSize =
  char: 1
  short: 2
  int: 4
  long: 8

genType = ->
  index = Math.floor Math.random() * 4
  type = ['char', 'short', 'int', 'long'][index]

  type: type
  size: typeToSize[type]

genStruct = ->
  type1 = genType()
  type2 = genType()

  padding = if type1['type'] is type2['type'] then 0 else type2['size'] - (type1['size'] % type2['size'])

  structSize = type1['size'] + padding + type2['size']

  type: """struct {
    #{type1['type']} a;
    #{type2['type']} b;
  }"""
  size: structSize

root.Generator = class Generator
  @basic: (struct) ->
    struct = struct ? false
    genB = ->
      1 << Math.floor(Math.random()*2 + 3)
    genS = ->
      1 << Math.floor(Math.random()*2 + 2)
    genE = ->
      1

    genSize = ->
      2*(Math.floor Math.random()*16 + 5)

    i = genSize()
    arrType = if struct then genStruct() else genType()

    arraySize = i*arrType['size']

    b = genB()
    while arraySize % b != 0
      i = genSize()
      b = genB()
      arrType = if struct then genStruct() else genType()

      arraySize = arraySize = i*arrType['size']

    code = ""
    if not struct
      code = """#{arrType['type']} array[#{i}];

for (int i = 0; i < #{i}; ++i) {
  array[i] = 10;
}"""
    else
      code = """#{arrType['type']} array[#{i}];

for (int i = 0; i < #{i}; ++i) {
  array[i].a = 10;
  array[i].b = 10;
}"""

    code: code
    s: genS()
    b: b
    E: genE()

  @easy: (struct) ->
    struct = struct ? false
    genB = ->
      1 << Math.floor(Math.random()*3 + 3)
    genS = ->
      1 << Math.floor(Math.random()*3 + 2)
    genE = ->
      Math.floor(Math.random()*2 + 1)

    genSize = ->
      2*(Math.floor Math.random()*9 + 2)

    i = genSize()
    j = genSize()

    arrType = if struct then genStruct() else genType()
    arraySize = arrType['size']*i*j
    b = genB()

    while arraySize % b != 0
      i = genSize()
      j = genSize()
      b = genB()
      arrType = if struct then genStruct() else genType()
      arraySize = arrType['size']*i*j

    loops = ["for (int i = 0; i < #{i}; ++i)", "for (int j = 0; j < #{j}; ++j)"]
    index = 1
    code = ""
    if not struct
      code =  """#{type} array[#{i}][#{j}];

#{loops[Math.abs(index - 1)]} {
  #{loops[index]} {
    array[i][j] = 15;
  }
}"""
    else
      code =  """#{type} array[#{i}][#{j}];

#{loops[Math.abs(index - 1)]} {
  #{loops[index]} {
    array[i][j].a = 15;
    array[i][j].b = 15;
  }
}"""

    code: code
    s: genS()
    b: b
    E: genE()

  @medium: (struct) ->
    genB = ->
      1 << Math.floor(Math.random()*3 + 3)
    genS = ->
      1 << Math.floor(Math.random()*3 + 3)
    genE = ->
      Math.floor(Math.random()*4 + 1)

    genSize = ->
      Math.floor(Math.random()*16) + 15

    i = genSize()
    j = genSize()

    arrType = if struct then genStruct() else genType()
    arraySize = arrType['size']*i*j
    b = genB()

    while arraySize % b != 0
      i = genSize()
      j = genSize()
      b = genB()
      arrType = if struct then genStruct() else genType()
      arraySize = arrType['size']*i*j

    loops = ["for (int i = 0; i < #{i}; ++i)", "for (int j = 0; j < #{j}; ++j)"]
    index = 0
    code = ""
    if not struct
      code =  """#{type} array[#{i}][#{j}];

#{loops[Math.abs(index - 1)]} {
  #{loops[index]} {
    array[i][j] = 15;
  }
}"""
    else
      code =  """#{type} array[#{i}][#{j}];

      #{loops[Math.abs(index - 1)]} {
        #{loops[index]} {
          array[i][j].a = 15;
          array[i][j].b = 15;
        }
      }"""

    code: code
    s: genS()
    b: b
    E: genE()
