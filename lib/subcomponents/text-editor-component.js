/** @babel */
/** @jsx etch.dom */

import etch from 'etch'

export default class TextEditorComponent {

  constructor(properties) {
    this.props = properties
    etch.initialize(this)
  }

  render() {
    return (
      <div>
        <atom-text-editor ref='atomTextEditor' attributes={this.props.attrs}/>
      </div>
    )
  }

  update(properties) {
    this.props = properties
    return etch.update(this)
  }

  // Tear down any state and detach
  async destroy() {

    await etch.destroy(this)
  }

  
}
