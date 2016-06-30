/** @babel */
/** @jsx etch.dom */

import etch from 'etch'

const items = [
  { ref: 'connect', menu: 'Connect', icon: 'icon-zap' },
  { ref: 'disconnect', menu: 'Disconnect', icon: 'icon-plug' },
  { ref: 'portsettings', menu: 'Port Settings', icon: 'icon-settings' }
]

export default class MenuComponent {

  constructor(properties) {
    this.itemstatus = ['inactive', 'inactive', '']
    etch.initialize(this)

  }

  render() {
    return (
      <div className='menu'>
        {this.renderMenuItems()}
      </div>
    )
  }

  renderMenuItems() {
    return (
      items.map( (item, index) =>
          <div ref={item.ref} className={'item ' + this.itemstatus[index]} >
            <div className={'icon large ' + item.icon} />
            <div>{item.menu}</div>
          </div>
      )
    )
  }

  update(properties) {
    return etch.update(this)
  }

  toggleConnect(active) {
    if (active) {
      this.itemstatus[0] = ''
    } else {
      this.itemstatus[0] = 'inactive'
    }

    return etch.update(this)
  }

  toggleDisconnect(active) {
    if (active) {
      this.itemstatus[1] = ''
    } else {
      this.itemstatus[1] = 'inactive'
    }

    return etch.update(this)
  }

  // Tear down any state and detach
  async destroy() {

    await etch.destroy(this)
  }

}
