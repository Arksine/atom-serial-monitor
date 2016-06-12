{View, TextEditorView} = require "atom-space-pen-views"

module.exports =
class SerialOutputView extends View
  outEditor: undefined

  @content: (params) ->
    attrs =
      id: 'output'
    @div class: 'serialoutput', =>
      @div class: 'block', =>
        @div class: 'control-row', =>
          @button id: 'sendbutton', class: 'btn', click: 'click', "Send"
          @select id: 'sendtype', class: 'form-control inline-block',
          outlet: 'sendType', =>
            @option value: 'Ascii', 'Ascii'
            @option value: 'Hex', 'Hex'
            @option value: 'Dec', 'Dec'
            @option value: 'Bin', 'Bin'
          @select id: 'append', class: 'form-control inline-block',
          outlet: 'appendEnd', =>
            @option value: 'None', 'No Line Ending'
            @option value: 'CRLF', 'CRLF'
            @option value: 'LF', 'LF'
            @option value: 'CR', 'CR'
          @subview 'outputView', new TextEditorView(mini: true,
          placeholderText: 'Enter Ascii text or Hex...', attrs)



  initialize: (params) ->



  click: ->
    text = @outputView.getText()
    switch @appendEnd.value
      when 'CRLF'
        text += '\r' + '\n'
      when 'LF'
        text += '\n'
      when 'CR'
        text += '\r'
    if (text != "")
      if (@find('#typeascii').hasClass('selected'))
        #TODO: send text over serial
      else
        #TODO: convert to hex and send over serial
