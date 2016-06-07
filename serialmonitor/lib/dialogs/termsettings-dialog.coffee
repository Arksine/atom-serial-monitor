Dialog = require './dialog'

module.exports =
class TermSettingsDialog extends Dialog
  @content: ->
    @div class: 'dialog', =>
      @div class: 'heading', =>
        @i class: 'icon icon-x clickable', click: 'cancel'
        @strong 'Terminal Settings'
      @div class: 'body', =>
        @div class: "column", =>
          @div class: 'horizontal-control', =>
            @label class:'setting-title', 'Show Received Data:'

      @div class: 'buttons', =>
        @button class: 'active', click: 'apply', =>
          @i class: 'icon icon-check'
          @span 'Apply'
        @button click: 'cancel', =>
          @i class: 'icon icon-x'
          @span 'Cancel'

  activate: ->
    return super()

  apply: ->
    @deactivate()
    return
