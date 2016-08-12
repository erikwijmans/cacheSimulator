root = exports ? this

root.AccessType = AccessType = Object.freeze
  hit: 1
  miss: 2
  evict: 3

nameMap =
  1: 'Hit'
  2: 'Miss'
  3: 'Evict'

height = 50
width = 50

root.CSim = class CSim
  constructor: (@s, @E, res, options) ->
    options = options ? {}
    @parent = options['parent'] ? $ 'body'
    @log = options['log']
    @numSets = (1 << @s)
    @currentIndex = 0
    @cache = []
    @out = []
    @states = []
    @hits = res['hits']
    @misses = res['misses']

    state = []
    for i in [0...@numSets]
      row = $("<div class='row'/>").appendTo @parent

      $ "<p class='col-md-2'
        style='margin-top: 15px;'>
        Set #{i}</p>"
        .appendTo row
      inner = $ "<div class='row col-md-10'/>"
        .appendTo row
      for _ in [0...@E]
        block = $ "<p class='block'/>"
          .text '-1'
          .appendTo(
            $ "<div class='col-md-3'/>"
              .appendTo inner
          )


        @cache.push block

        state.push
          tag: -1
          type: 0

    @states.push state
    @out.push ""

    for line in res['trace']
      console.log line

      block = line['block']
      tag = line['tag']
      accType = line['acc_type']
      address = line['address']
      set = line['set']

      if @log?
        @out.push "Address: 0x#{address.toString 16}  Tag: 0x#{tag.toString 16}  Set: #{set}  #{nameMap[accType]}"


      newState = (s for s in @states[@states.length - 1])
      newState[block] =
        tag: tag
        type: accType

      @states.push newState

  print: ->
    if @log?
      @log.html "<br>#{@out[0..@currentIndex].reverse().join("<br><br>")}"

    for b, i in @states[@currentIndex]
      @cache[i].removeClass "hit miss evict"
      @cache[i].text if b.tag != -1 then "0x#{b.tag.toString 16}" else b.tag
      switch b.type
        when 0
          break
        when AccessType.hit
          @cache[i].addClass "hit"
        when AccessType.miss
          @cache[i].addClass "miss"
        when AccessType.evict
          @cache[i].addClass "evict"
        else
          console.log "Unsupported Type: #{b.type}"

    true

  next: ->
    if @hasNext()
      ++@currentIndex
      @print()
      true
    else
      false

  prev: ->
    if @hashPrev()
      --@currentIndex
      @print()
      true
    else
      false

  hasNext: ->
    @currentIndex + 1 < @states.length

  hasPrev: ->
    @currentIndex >= 0



data = JSON.parse '{"misses": 20, "trace": [{"acc_type": 2, "tag": 32, "address": 4164, "block": 204, "set": 17}, {"acc_type": 2, "tag": 0, "address": 0, "block": 0, "set": 0}, {"acc_type": 2, "tag": 32, "address": 4160, "block": 192, "set": 16}, {"acc_type": 2, "tag": 0, "address": 8, "block": 24, "set": 2}, {"acc_type": 2, "tag": 35, "address": 4564, "block": 252, "set": 21}, {"acc_type": 2, "tag": 6, "address": 800, "block": 96, "set": 8}, {"acc_type": 2, "tag": 35, "address": 4560, "block": 240, "set": 20}, {"acc_type": 2, "tag": 6, "address": 808, "block": 120, "set": 10}, {"acc_type": 2, "tag": 38, "address": 4964, "block": 300, "set": 25}, {"acc_type": 2, "tag": 12, "address": 1600, "block": 193, "set": 16}, {"acc_type": 2, "tag": 38, "address": 4960, "block": 288, "set": 24}, {"acc_type": 2, "tag": 12, "address": 1608, "block": 216, "set": 18}, {"acc_type": 2, "tag": 41, "address": 5364, "block": 348, "set": 29}, {"acc_type": 2, "tag": 18, "address": 2400, "block": 289, "set": 24}, {"acc_type": 2, "tag": 41, "address": 5360, "block": 336, "set": 28}, {"acc_type": 2, "tag": 18, "address": 2408, "block": 312, "set": 26}, {"acc_type": 2, "tag": 45, "address": 5764, "block": 12, "set": 1}, {"acc_type": 2, "tag": 25, "address": 3200, "block": 1, "set": 0}, {"acc_type": 2, "tag": 45, "address": 5760, "block": 2, "set": 0}, {"acc_type": 2, "tag": 25, "address": 3208, "block": 25, "set": 2}], "hits": 0}'


sim = new CSim 5, 12, data,
  parent: $("<div class='container cache'/>").appendTo $ '#content'
  log: $('<p class="log"/>').appendTo $ '#content'

simFunc = () ->
  if sim.hasNext()
    sim.next()
    setTimeout simFunc, 1000

simFunc()


