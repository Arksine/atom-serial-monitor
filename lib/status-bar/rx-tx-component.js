/** @babel */
/** @jsx etch.dom */

import etch from 'etch'
import StatusBarComponent from './status-bar-component'

export default class RxTxComponent extends StatusBarComponent {
  constructor(label) {
    super()
    this.label = label
    this.count = 0;
  }

  render() {
    return(
      <a className={'inline-block '+ (this.active ? '' : 'hidden')}>
        {this.label}:&nbsp;{this.count}
      </a>
    )
  }

  update(count) {
    this.count = count
    return etch.update(this)
  }
}
