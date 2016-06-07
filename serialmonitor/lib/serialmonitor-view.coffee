{View, $, $$} = require 'atom-space-pen-views'

MenuView = require "./views/menu-view"
QuickPortSettingsView = require './views/quickportsettings-view'
TerminalSettingsView = require "./views/terminalsettings-view"
SerialInputView = require "./views/serialinput-view"
SerialOutputView = require "./views/serialoutput-view"

PortSettingsDialog = require "./dialogs/portsettings-dialog"


module.exports =
class SerialmonitorView extends View
  @content: ->
    @div class: 'serialmonitor', =>
      @subview 'menuView', new MenuView()
      @subview 'terminalSettings', new TerminalSettingsView()
      @div class: 'terminal', outlet: 'terminalView', =>
        @subview 'serialInputView', new SerialInputView()
        @subview 'portSettingsDialog', new PortSettingsDialog()
      @subview 'serialOutputView', new SerialOutputView()


  serialize: ->

  initialize: ->

  deactivate: ->
    return
  getTitle: ->
    return 'Serial Monitor'

  update: (nofetch) ->
    return

  connectMenuClick: ->
    return

  disconnectMenuClick: ->
    return

  portsettingsMenuClick: ->
    @portSettingsDialog.activate();
    return
