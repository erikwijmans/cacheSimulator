root = exports ? this

typeToSize =
  char: 1
  short: 2
  int: 4
  long: 8

genB = () ->
  1 << Math.floor(Math.random()*3 + 2)
genS = () ->
  1 << Math.floor(Math.random()*3 + 1)
genE = () ->
  Math.floor(Math.random()*2 + 1)

root.Generator = class Generator

  @easy: () ->
    i = Math.floor Math.random()*15 + 5
    j = Math.floor Math.random()*15 + 5
    type = ['char', 'short', 'int', 'long'][Math.floor Math.random() * 5]
    loops = ["for (int i = 0; i < #{i}; ++i)", "for (int j = 0; j < #{j}; ++j)"]
    index = Math.floor Math.random()*2
    code =  """#{type} array[#{i}][#{j}];

    #{loops[Math.abs(index - 1)]} {
      #{loops[index]} {
        array[i][j] = 15;
      }
    }"""


    arraySize = typeToSize[type]*i*j
    b = genB()
    while arraySize % b is not 0
      b = genB()

    code: code
    s: genS()
    b: b
    E: genE()