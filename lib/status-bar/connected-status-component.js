/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import StatusBarComponent from './status-bar-component'

export default class ConnectedStatusComponent extends StatusBarComponent {
  constructor(properties) {
    super()
    this.setupProperties(properties)
  }

  setupProperties(properties) {
    this.connected = properties.connected
    this.serConnStatus = this.connected ? 'Connected' : 'Disconnected'
    this.comPort = properties.port
    if (this.comPort === '0') {
      this.comPort = "No Port Selected"
    }
  }

  render() {
    return(
      <div className={'status-bar-component inline-block '
      + (this.active ? '' : 'hidden')}>
        <span className={'item ' + (this.connected ? 'connected' : '')}>
          {this.serConnStatus}
        </span>
        <span className='item'>{this.comPort}</span>
      </div>
    )
  }

  update(properties){
    this.setupProperties(properties)
    return etch.update(this)
  }
}
