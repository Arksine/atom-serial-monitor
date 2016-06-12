{View, $, $$} = require 'atom-space-pen-views'
SerialPort = require "./pyserialclient"

MenuView = require "./views/menu-view"
QuickPortSettingsView = require './views/quickportsettings-view'
TerminalSettingsView = require "./views/terminalsettings-view"
SerialReceivedView = require "./views/serialreceived-view"
SerialOutputView = require "./views/serialoutput-view"

PortSettingsDialog = require "./dialogs/portsettings-dialog"

module.exports =
class SerialmonitorView extends View
  port: undefined
  portsettings: undefined

  @content: ->
    @div class: 'serialmonitor', =>
      @subview 'menuView', new MenuView()
      @subview 'terminalSettings', new TerminalSettingsView()
      @div class: 'terminal', outlet: 'terminalView', =>
        @subview 'serialInputView', new SerialReceivedView()
        @subview 'portSettingsDialog', new PortSettingsDialog()
      @subview 'serialOutputView', new SerialOutputView()


  serialize: ->

  initialize: ->
    @port = new SerialPort(this)

  destroy: ->
    @port.destroy()
    @active = false
    return

  getTitle: ->
    return 'Serial Monitor'

  update: (nofetch) ->
    return

  connectMenuClick: ->
    if @portsettings != undefined && @portsettings.port != '0'
      @port.connectPort(portsettings)
    else
      #TODO: change this to build in atom/electron dialog if possible
      alert('Please select a valid serial port.')
    return

  disconnectMenuClick: ->
    @port.disconnectPort()
    return

  portsettingsMenuClick: ->
    #if @portsettings == undefined
      #@requestPortList()
    @portSettingsDialog.activate()
    return

  requestPortList: ->
    @port.getPortList()
    return

  writeToSerial: (data) ->
    @port.writeToSerial(data)

  # port dialog callbacks
  onPortSettingsApplied: (portsettings) ->
    @portsettings = portsettings
    return

  onPortSettingUpdated: (setting) ->
    @port.updateSetting(setting)
    return

  # SocketIO callbacks
  onSerialReceived: (data) ->
    #for i in data
      # TODO: call the function to add characters to the serial input view
    return

  onPortConnected: ->
    @portSettingsDialog.toggleConnected(true)
    @menuView.toggleMenuItem('connect', off)
    @menuView.toggleMenuItem('disconnect', on)
    return

  onPortDisconnected: ->
    @portSettingsDialog.toggleConnected(false)
    @menuView.toggleMenuItem('connect', on)
    @menuView.toggleMenuItem('disconnect', off)
    return

  onPortListReceived: (portlist) ->
    @portSettingsDialog.refreshPortList(portlist)
    return
