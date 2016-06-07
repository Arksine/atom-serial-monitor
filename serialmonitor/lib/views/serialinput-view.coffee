{View} = require "atom-space-pen-views"

bytetoHex = (byte) ->
  return ('0' + (byte & 0xFF).toString(16)).slice(-2)

class TextLine extends View
  @content: (params) ->
    @div class: "line hex", =>
      @pre outlet: "hextext"
    @div class: "line ascii", =>
      @pre outlet: "asciitext"

    @hextext.hide() unless params.hexOn is on
    @asciitext.hide() unless params.asciiOn is on

 add: (byte) ->
   if (byte is '\n' or '\r')
     @hextext.innerHtml += byte;
   else
     hexString = bytetoHex(byte)
     @hextext.innerHtml += hexString;

   @asciitext.innerHtml += byte
   return

module.exports =
class SerialInputView extends View
  currentLine: undefined
  hexEnabled: off
  asciiEnabled: on

  @content: ->
    @div class: 'serialinput'

  @initialize: (params) ->
    hexEnabled = params.hex
    asciiEnabled = params.ascii
    currentLine = new TextLine(hexOn: hexEnabled, asciiOn: asciiEnabled)
    @append currentLine

  clearAll: ->
    @find('>.line').remove()
    return

  addByte: (byte) ->
    #TODO: I may need to handle carraige returns better here
    @currentLine.add(byte)
    if byte is '\n'
        # we have a new line, so create a new text line
        currentLine = new TextLine(hexOn: hexEnabled, asciiOn: asciiEnabled)
        @append currentLine
    return

  toggleHex: ->
    if hexEnabled is on
      hexEnabled = off
      @find('>.line.hex').hide()
    else
      hexEnabled = on
      @find('>.line.hex').show()
    return

  toggleAscii: ->
    if asciiEnabled is on
      hexEnabled = off
      @find('>.line.ascii').hide()
    else
      hexEnabled = on
      @find('>.line.ascii').show()
    return
