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
    @home = $ "<div/>"
      .appendTo @parent

    if @summary?
      @summary.html "Summary <br/>
    Hits: #{res['hits']} <br/>
    Misses: #{res['misses']} <br/>
    Miss Ratio: #{res['miss_rate']}"

    controlDiv = $ "<div class='row'/>"
      .appendTo @home

    $ "<div class='col-md-4'/>"
      .appendTo controlDiv
      .append($ "<button class='btn' id='autobtn'/>"
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

    $ "<div class='col-md-4'/>"
      .appendTo controlDiv
      .append($ "<button class='btn'/>"
      .text "Next"
      .click () =>
        @next()
      )

    $ "<div class='col-md-4'/>"
      .appendTo controlDiv
      .append($ "<button class='btn'/>"
      .text "Prev"
      .click () =>
        @prev()
      )

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
        @out.push "Address: 0x#{address.toString 16}  Tag: 0x#{tag.toString 16}  Set: #{set}  #{nameMap[accType]}"


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
  powOf2: 0
  nonPowOf2: 1
  nan: 2

powOf2Checker = (num) ->
  if isNaN(num)
    STATUS.nan
  else
    if (num | (num - 1)) is (num + num - 1) then STATUS.powOf2 else STATUS.nonPowOf2


root.SimManager = class SimManager
  constructor: (@home, @simbtn) ->
    nameDiv = $ "<div class='row'/>"
      .appendTo @home

    $ "<div class='col-md-3'/>"
      .text "Number of Sets"
      .appendTo nameDiv

    $ "<div class='col-md-3'/>"
      .text "Bytes per Block"
      .appendTo nameDiv

    $ "<div class='col-md-3'/>"
      .text "Associativity"
      .appendTo nameDiv

    $ "<div class='col-md-3'/>"
      .text "Memory Size"
      .appendTo nameDiv

    inputDiv = $ "<div class='row'/>"
      .appendTo @home

    @checkDir = {}
    @createCheckedInput 's', 1 << parseInt(Math.random()*4 + 1), inputDiv
    @createCheckedInput 'b', 1 << parseInt(Math.random()*4 + 1), inputDiv


    $ "<div class='col-md-3'/>"
      .appendTo inputDiv
      .append($ "<input type='number' id='E'/>"
        .val parseInt Math.random()*6 + 1
        .attr "style", "width: 100%;"
        )

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



  createCheckedInput: (id, initialVal, parent) ->
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
          .on 'input', () =>
            @checkInput id
          )

    @checkDir[id] = true


  checkInput: (id) ->
    val = parseInt($("##{id}").val())
    stat = powOf2Checker val

    switch stat
      when STATUS.powOf2
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