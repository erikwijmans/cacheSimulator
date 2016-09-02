root = exports ? this

typeToSize =
  char: 1
  short: 2
  int: 4
  long: 8

genType = ->
  index = Math.floor Math.random() * 4
  ['char', 'short', 'int', 'long'][index]



root.Generator = class Generator
  @basic: ->
    genB = ->
      1 << Math.floor(Math.random()*2 + 3)
    genS = ->
      1 << Math.floor(Math.random()*3 + 1)
    genE = ->
      1

    genSize = ->
      2*(Math.floor Math.random()*16 + 5)

    i = genSize()
    index = Math.floor Math.random() * 4
    type = genType()
    arraySize = i*typeToSize[type]

    b = genB()
    while arraySize % b != 0
      i = genSize()
      b = genB()

      type = genType()
      arraySize = i*typeToSize[type]


    code = """#{type} array[#{i}];

for (int i = 0; i < #{i}; ++i) {
  array[i] = 10;
}"""

    code: code
    s: genS()
    b: b
    E: genE()

  @easy: ->
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

    type = genType()
    arraySize = typeToSize[type]*i*j
    b = genB()

    while arraySize % b != 0
      i = genSize()
      j = genSize()
      b = genB()
      type = genType()
      arraySize = typeToSize[type]*i*j

    loops = ["for (int i = 0; i < #{i}; ++i)", "for (int j = 0; j < #{j}; ++j)"]
    index = 1
    code =  """#{type} array[#{i}][#{j}];

    #{loops[Math.abs(index - 1)]} {
      #{loops[index]} {
        array[i][j] = 15;
      }
    }"""

    code: code
    s: genS()
    b: b
    E: genE()

  @medium: ->
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

    type = genType()
    arraySize = typeToSize[type]*i*j
    b = genB()

    while arraySize % b != 0
      i = genSize()
      j = genSize()
      b = genB()
      type = genType()
      arraySize = typeToSize[type]*i*j

    loops = ["for (int i = 0; i < #{i}; ++i)", "for (int j = 0; j < #{j}; ++j)"]
    index = 0
    code =  """#{type} array[#{i}][#{j}];

    #{loops[Math.abs(index - 1)]} {
      #{loops[index]} {
        array[i][j] = 15;
      }
    }"""

    code: code
    s: genS()
    b: b
    E: genE()
