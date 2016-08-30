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
    @summary = options['summary']
    @numSets = (1 << @s)
    @currentIndex = 0
    @cache = []
    @out = []
    @states = []
    @missRati
    @intervalID = null
    @home = $ "<div class='row'/>"
      .appendTo @parent

    if @summary?
      @summary.html "
    Hits: #{res['hits']} <br/>
    Misses: #{res['misses']} <br/>
    Miss Ratio: #{res['miss_rate']}"


    $ "<div class='row'/>"
      .appendTo @home
      .append $ "<label><br/>Controls</label>"

    controlDiv = $ "<div class='row'/>"
      .appendTo @home

    $ "<div class='col-md-3'/>"
      .appendTo controlDiv
      .append($ "<button class='btn btn-default' id='autobtn'/>"
        .attr "role", "start"
        .text "Auto"
        .click () =>
          if $("#autobtn").attr('role') is 'start'
            autoFunc = () =>
              @intervalID = setInterval () =>
                @next()
                if not @hasNext()
                  clearInterval @intervalID
              , 1000

            autoFunc()

            $("#autobtn").text "Stop"
              .attr "role", 'stop'
          else
            clearInterval @intervalID
            $("#autobtn").text "Auto"
              .attr "role", 'start'
      )

    $ "<div class='col-md-3'/>"
      .appendTo controlDiv
      .append($ "<button class='btn btn-default'/>"
        .text "Next"
        .click () =>
          @next()
      )

    $ "<div class='col-md-3'/>"
      .appendTo controlDiv
      .append($ "<button class='btn btn-default'/>"
        .text "Prev"
        .click () =>
          @prev()
      )

    $ "<div class='col-md-3'/>"
      .appendTo controlDiv
      .append($ "<button class='btn btn-default'/>"
        .text "Reset"
        .click () =>
          @currentIndex = 0
          @print()
      )


    $ "<div class='row'/>"
      .appendTo @home
      .append $ "<label><br/>Cache</label>"

    state = []
    for i in [0...@numSets]
      row = $("<div class='row'/>").appendTo @home

      $ "<p class='col-md-2'
        style='margin-top: 15px;'>
        Set #{i}</p>"
        .appendTo row
      inner = $ "<div class='row col-md-10'/>"
        .appendTo row
      for _ in [0...@E]
        block = $ "<p class='block empty'/>"
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

      block = line['block']
      tag = line['tag']
      accType = line['acc_type']
      address = line['address']
      set = line['set']

      if @log?
        @out.push "<strong>Address:</strong> 0x#{address.toString 16}  <strong>Tag:</strong> 0x#{tag.toString 16}  <strong>Set:</strong> #{set}  <strong>#{nameMap[accType]}</strong>"

      newState = @states[@states.length - 1][..]
      newState[block] =
        tag: tag
        type: accType

      @states.push newState

  print: ->
    if @log?
      text = "#{@out[1..@currentIndex].join("<br><br>")}<br>"
      console.log text
      @log.html text
      @log.scrollTop @log[0].scrollHeight

    for b, i in @states[@currentIndex]
      @cache[i].removeClass "hit miss evict empty"
      @cache[i].text if b.tag != -1 then "0x#{b.tag.toString 16}" else b.tag
      switch b.type
        when 0
          @cache[i].addClass "empty"
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
    if @hasPrev()
      --@currentIndex
      @print()
      true
    else
      false

  hasNext: ->
    @currentIndex + 1 < @states.length

  hasPrev: ->
    @currentIndex > 0

  destroy: ->
    @home.remove()

    if @log?
      @log.text ""

    clearInterval @intervalID


STATUS = Object.freeze
  OK: 0
  nonPowOf2: 1
  nan: 2

powOf2Checker = (num) ->
  if isNaN(num)
    STATUS.nan
  else
    if (num | (num - 1)) is (num + num - 1) then STATUS.OK else STATUS.nonPowOf2


root.SimManager = class SimManager
  constructor: (@home, @simbtn, params) ->
    nameDiv = $ "<div class='row'/>"
      .appendTo @home

    $ "<h3 class='col-md-3 panel-title'/>"
      .text "Number of Sets"
      .appendTo nameDiv

    $ "<h3 class='col-md-3 panel-title'/>"
      .text "Bytes per Block"
      .appendTo nameDiv

    $ "<h3 class='col-md-3 panel-title'/>"
      .text "Associativity"
      .appendTo nameDiv

    $ "<h3 class='col-md-3 panel-title'/>"
      .text "Memory Size"
      .appendTo nameDiv

    inputDiv = $ "<div class='row'/>"
      .appendTo @home

    params = params ? {}

    @checkDir = {}
    @createCheckedInput 's', params['s'], inputDiv, powOf2Checker
    @createCheckedInput 'b', params['b'], inputDiv, powOf2Checker
    @createCheckedInput 'E', params['E'], inputDiv, (val) ->
      if isNaN(val) then STATUS.nan else STATUS.OK


    $ "<div class='col-md-3'/>"
      .appendTo inputDiv
      .append($ "<input type='number' id='memSize'/>"
        .val "64"
        .attr "style", "width: 100%;"
        )

  getParams: ->
    s: parseInt Math.log($("#s").val()) / Math.log(2)
    b: parseInt Math.log($("#b").val()) / Math.log(2)
    E: parseInt($("#E").val())
    memSize: parseInt($("#memSize").val())

  setParams: (p) ->
    $ "#s"
      .val p.s
      .trigger "change"
    $ "#b"
      .val p.b
      .trigger "change"
    $ "#E"
      .val p.E
      .trigger "change"

  createCheckedInput: (id, initialVal, parent, checker) ->
    $ "<div class='col-md-3'/>"
        .appendTo parent
        .append($ "<input type='number' id='#{id}'
                  data-toggle='tooltip'
                  data-placement='auto'
                  data-trigger='manual'
                  />"
          .tooltip()
          .val initialVal
          .attr "style", "width: 100%;"
          .on 'input change', () =>
            @checkInput id, checker
          .trigger "change"
          )


  checkInput: (id, checker) ->
    val = parseInt $("##{id}").val()
    stat =  checker val

    switch stat
      when STATUS.OK
        $("##{id}").tooltip 'hide'

        @checkDir[id] = true
      when STATUS.nonPowOf2
        $ "##{id}"
          .attr 'data-original-title', 'Must be a power of 2'
          .tooltip 'fixTitle'
          .tooltip 'show'

        @checkDir[id] = false
      when STATUS.nan
        $ "##{id}"
          .attr 'data-original-title', 'Must be a number'
          .tooltip 'fixTitle'
          .tooltip 'show'

        @checkDir[id] = false
      else
        console.log "STATUS of #{stat} is unsupported"

    isAllTrue = true
    for own _, val of @checkDir
      if not val
        isAllTrue = false
        break


    if isAllTrue
      @simbtn.removeClass 'disabled'
    else
     @simbtn.addClass 'disabled'