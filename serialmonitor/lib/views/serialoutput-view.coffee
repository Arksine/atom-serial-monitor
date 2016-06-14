{View, TextEditorView} = require "atom-space-pen-views"

hexStringToBin = (data) ->
  invalidHex = new RegExp(/[^A-Fa-f0-9]/)
  hexStart = new RegExp('0x', 'g')
  data = data.replace(/\s/g, "")
  data = data.replace(hexStart, "")
  data = data.replace(/\$/g, "")
  if (((data.length % 2) != 0) or invalidHex.test(data))
    alert("Invalid hex string")
    return ''

  result = []
  while (data.length >= 2)
    result.push(parseInt(data.substring(0, 2), 16) & 0xFF)
    data = data.substring(2, data.length)
  console.log(result)
  return result

module.exports =
class SerialOutputView extends View
  outEditor: undefined

  @content: (params) ->

    @div class: 'serialoutput', =>
      @div class: 'control-row', =>
        @button id: 'sendbutton', class: 'btn', click: 'send', "Send"
        @select id: 'sendtype', class: 'form-control inline-block',
        outlet: 'sendType', =>
          @option value: 'ascii', 'Ascii'
          @option value: 'hex', 'Hex'
          #@option value: 'dec', 'Dec'
          #@option value: 'bin', 'Bin'
        @subview 'outputView', new TextEditorView(mini: true,
        placeholderText: 'Enter Ascii text or Hex...')
        @select id: 'append', class: 'form-control inline-block',
        outlet: 'appendEnd', =>
          @option value: 'None', 'No Line Ending'
          @option value: 'CRLF', 'CRLF'
          @option value: 'LF', 'LF'
          @option value: 'CR', 'CR'

  initialize: (params) ->

  send: ->
    text = @outputView.getText()

    if @sendType.val() == 'ascii'
      switch @appendEnd.val()
        when 'CRLF'
          text += '\r' + '\n'
        when 'LF'
          text += '\n'
        when 'CR'
          text += '\r'
      if (text != '')
        console.log(text)
        @parentView.writeToSerial(text)
    else
      converted = hexStringToBin(text)
      if converted
        switch @appendEnd.val()
          when 'CRLF'
            converted.push(0x0d)
            converted.push(0x0a)
          when 'LF'
            converted.push(0x0a)
          when 'CR'
            converted.push(0x0d)
        if converted.length > 0
          buf = new Buffer(converted)
          console.log(buf)
          @parentView.writeToSerial(buf)
