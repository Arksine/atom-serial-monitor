/** @babel */

import SerialMonitorComponent from './serial-monitor-component'
import { CompositeDisposable } from 'atom'
import StatusBarManager from './status-bar-manager'

export default {

  serialMonitorComponent: null,
  statusBarManager: null,
  pane: null,
  item: null,

  activate(state) {
    this.subscriptions = new CompositeDisposable()

    this.subscriptions.add(atom.workspace.onDidChangeActivePaneItem((item) => {
      if (this.item === item) {
        this.statusBarManager.show()
      } else {
        this.statusBarManager.hide()
      }
    }))

    // Register command that toggles this view
    this.subscriptions.add(atom.commands.add('atom-workspace', {
      'serial-monitor:open': () => this.openView()
    }))

    this.subscriptions.add(atom.commands.add(
      '.serial-monitor .serialreceived', {
      'serial-monitor:copy': () =>
        this.serialMonitorComponent.copy()
    }))
  },

  deactivate() {
    //this.pane.destroy();
    this.subscriptions.dispose()
    this.serialMonitorComponent.destroy()
    this.statusBarManager.destroy()

  },

  consumeStatusBar (statusBar) {
    this.statusBarManager.createTiles(statusBar)
  },

  serialize() {
    return {
      atomSerialMonitorViewState: this.serialMonitorComponent.serialize()
    }
  },

  openView() {
    console.log('Serial Monitor was opened!')
    if (!this.serialMonitorComponent) {
      this.statusBarManager = new StatusBarManager()
      this.serialMonitorComponent = new SerialMonitorComponent({
        sb: this.statusBarManager})
      this.pane = atom.workspace.getActivePane()
      this.item = this.pane.addItem(this.serialMonitorComponent, 0)
      this.pane.activateItem(this.item)
    } else if (!this.serialMonitorComponent.active) {
      this.serialMonitorComponent.initialize()
      this.pane.activateItem(this.item)
      this.pane.moveItem(this.item, 0)
    } else if (this.pane.getActiveItem() != this.item) {
      this.pane.activateItem(this.item)
      this.pane.moveItem(this.item, 0)
    }
  }
}
