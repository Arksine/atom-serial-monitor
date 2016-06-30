/** @babel */
/** @jsx etch.dom */

import etch from 'etch'

export default class StatusBarComponent {
  constructor() {
    this.active = true
    etch.initialize(this)
  }

  async destroy() {
    await etch.destroy(this)
  }

  hide() {
    this.active = false
    return etch.update(this)
  }

  show() {
    this.active = true
    return etch.update(this)
  }
}
