SerialmonitorView = require './serialmonitor-view'
{CompositeDisposable} = require 'atom'

views = []
view = undefined
pane = undefined
item = undefined

module.exports = Serialmonitor =
  subscriptions: null

  activate: (state) ->
    console.log 'SerialMonitor: activate'
    atom.workspace.onDidChangeActivePaneItem (item) => @updateViews()

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      'serialmonitor:open': => @openView()



  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  openView: ->
    console.log 'Serialmonitor: toggle'

    unless view and view.active
      view = new SerialmonitorView()
      views.push view

      pane = atom.workspace.getActivePane()
      item = pane.addItem view, 0

      pane.activateItem item

    else
      pane.destroyItem item

    return

  updateViews: ->
    activeView = atom.workspace.getActivePane().getActiveItem()
    for v in views when v is activeView
      v.update()
    return
