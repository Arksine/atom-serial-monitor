/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import StatusBarComponent from './status-bar-component'

export default class PortOptionsComponent extends StatusBarComponent {
  constructor(properties) {
    super()
    this.setupProperties(properties)

  }

  setupProperties(properties) {
    this.baud = properties.baud.toString()
    var parity = ''
    switch (properties.parity) {
      case 'none':
        parity = 'N'
        break
      case 'even':
        parity = 'E'
        break
      case 'odd':
        parity = 'O'
        break
      case 'mark':
        parity = 'M'
        break
      case 'space':
        parity = 'S'
        break
    }

    this.serInfo =  properties.databits + ":" +
    parity + ':' + properties.stopbits

    if (properties.xonxoff) {
      this.flow = 'Xon\\Xoff'
    } else if (properties.rtscts) {
      this.flow = 'RTS\\CTS'
    } else if (properties.dsrdtr) {
      this.flow = 'DSR\\DTR'
    } else {
      this.flow = ''
    }
  }

  render() {
    return(
      <div className={'status-bar-component inline-block '
      + (this.active ? '' : 'hidden')}>
        <span className='item'>{this.baud}</span>
        <span className='item'>{this.serInfo}</span>
        <span className='item'>{this.flow}</span>
      </div>
    )
  }

  update(properties) {
    this.setupProperties(properties)
    return etch.update(this)
  }
}
