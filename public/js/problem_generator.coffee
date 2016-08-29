root = exports ? this

typeToSize =
  char: 1
  short: 2
  int: 4
  long: 8

genB = ->
  1 << Math.floor(Math.random()*3 + 3)
genS = ->
  1 << Math.floor(Math.random()*3 + 2)
genE = ->
  Math.floor(Math.random()*2 + 1)

genSize = ->
  2*(Math.floor Math.random()*9 + 2)

root.Generator = class Generator

  @easy: () ->
    i = genSize()
    j = genSize()
    index = Math.floor Math.random() * 4
    type = ['char', 'short', 'int', 'long'][index]
    arraySize = typeToSize[type]*i*j
    b = genB()

    while arraySize % b != 0
      i = genSize()
      j = genSize()
      index = Math.floor Math.random() * 4
      type = ['char', 'short', 'int', 'long'][index]
      arraySize = typeToSize[type]*i*j
      b = genB()

    loops = ["for (int i = 0; i < #{i}; ++i)", "for (int j = 0; j < #{j}; ++j)"]
    index = Math.floor Math.random()*2
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