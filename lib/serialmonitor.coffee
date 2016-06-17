SerialmonitorView = require './serialmonitor-view'
{CompositeDisposable} = require 'atom'
db = require 'diskdb'
path = require 'path'

config =
  title: 'data'
  portsettings:
    port: '0'
    baud: 9600
    databits: 8
    stopbits: 1
    parity: 'none'
    xonxoff: false
    rtscts: false
    dsrdtr: false
    dtr: true
    rts: true
  termsettings:
    hexEnabled: on
    asciiEnabled: on
  sendsettings:
    sendType: 'ascii'
    endLine: 'None'


view = null
pane = null
item = null

module.exports = Serialmonitor =
  subscriptions: null
  initcfg: null
  cfg: null

  activate: (state) ->
    console.log 'SerialMonitor: activate'
    #atom.workspace.onWillDestroyPane (pane) => destroy()
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'serialmonitor:open': => @openView()

  deactivate: ->
    #TODO: save data

    @subscriptions.dispose()

  updateConfig: ->
    console.log 'SerialMonitor: destroy'
    db.serialmonitorconfig.update(@initcfg[0], @cfg)

  serialize: ->

  openView: ->
    # retreive stored data here
    configpath = path.join(__dirname, '../config')
    db.connect(configpath, ['serialmonitorconfig'])
    @initcfg = db.serialmonitorconfig.find()
    if @initcfg.length == 0
      db.serialmonitorconfig.save(config)
      @initcfg = db.serialmonitorconfig.find()

    @cfg = Object.assign({} , @initcfg[0])

    if not view
      view = new SerialmonitorView(@cfg)
      pane = atom.workspace.getActivePane()
      item = pane.addItem view, 0
      pane.activateItem item
      pane.onDidRemoveItem (event) =>
        if event.item == item
          @updateConfig()
      @active = true
    else if not view.active
      pane.activateItem item
      pane.moveItem item, 0
      view.update(@cfg)
      @active = true
    return
