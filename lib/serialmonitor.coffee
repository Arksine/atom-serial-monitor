SerialmonitorView = require './serialmonitor-view'
{CompositeDisposable} = require 'atom'

data = {
  portsettings: undefined
  termHex: on
  termAscii: on
}

module.exports = Serialmonitor =
  subscriptions: null
  view: null
  pane: null
  item: null


  activate: (state) ->
    console.log 'SerialMonitor: activate'
    #atom.workspace.onDidChangeActivePaneItem (item) => @updateViews()

    #TODO: retreive stored data here.

    @view = new SerialmonitorView(data)
    @pane = atom.workspace.getActivePane()
    @item = @pane.addItem @view, 0

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'serialmonitor:open': => @openView()

  deactivate: ->
    #TODO: save data
    @subscriptions.dispose()
    @view.destroy()

  serialize: ->

  openView: ->
    unless @view and @view.active
      @pane.activateItem @item
    return
