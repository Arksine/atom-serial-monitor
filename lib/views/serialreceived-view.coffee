{View} = require "atom-space-pen-views"

bytetoHex = (byte) ->
  hexstr = '0' + (byte.charCodeAt(0) & 0xFF).toString(16)
  return hexstr.slice( - 2)

class TextLine extends View
  @content: ->
    @div =>
      @div class: "line hex", outlet: 'hexline'
      @div class: "line ascii", outlet: 'asciiline', =>
        @pre outlet: "asciitext", ''

  initialize: (cfg) ->
    @hexline.hide() unless cfg.hexEnabled is on
    @asciiline.hide() unless cfg.asciiEnabled is on

  add: (byte) ->
    hexblock = "<pre>" + bytetoHex(byte) + "</pre>"
    @hexline.append(hexblock)

    ascout = byte
    if (byte == '\r')
      ascout = "<sup>\\r</sup>"
    else if (byte == '\n')
      ascout = "<sup>\\n</sup>"
    @asciitext.append(ascout)
    return

module.exports =
class SerialReceivedView extends View
  currentLine: undefined
  hexEnabled: on
  asciiEnabled: on

  @content: ->
    @div class: 'serialreceived'

  initialize: (cfg) ->
    @hexEnabled = cfg.hexEnabled
    @asciiEnabled = cfg.asciiEnabled
    @currentLine = new TextLine(cfg)
    @append @currentLine

  update: (cfg) ->
    @clearAll()
    @initialize(cfg)

  clearAll: ->
    @find('.line').remove()
    return

  addByte: (byte) ->
    @currentLine.add(byte)

    #TODO: I may need to handle carraige returns better here
    if byte is '\n'
      # we have a new line, so create a new text line
      @currentLine = new TextLine(hexEnabled: @hexEnabled,
      asciiEnabled: @asciiEnabled)
      @append @currentLine
      @scrollToBottom()

    #xscroll = @scrollLeft() + @width()
    #@scrollLeft(xscroll)
    return

  toggleHex: ->
    if @hexEnabled is on
      @hexEnabled = off
      @find('.line.hex').hide()
    else
      @hexEnabled = on
      @find('.line.hex').show()
    return @hexEnabled

  toggleAscii: ->
    if @asciiEnabled is on
      @asciiEnabled = off
      @find('.line.ascii').hide()
    else
      @asciiEnabled = on
      @find('.line.ascii').show()
    return @asciiEnabled
