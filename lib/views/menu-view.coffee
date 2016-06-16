{View, $} = require 'atom-space-pen-views'

items = [
  { id: 'connect', menu: 'Connect', icon: 'icon-zap', type: 'active'}
  { id: 'disconnect', menu: 'Disconnect', icon: 'icon-plug', type: 'inactive'}
  { id: 'portsettings', menu: 'Port Settings', icon: 'icon-settings',
  type: 'active'}
]

class MenuItem extends View
  @content: (item) ->
    klass = if item.type is 'active' then '' else 'inactive'

    @div class: "item #{klass}", id: "menu#{item.id}",  click:  'click',  =>
      @div class: "icon large #{item.icon}"
      @div item.menu

  initialize: (item) ->
    @item = item

  click: ->
    @parentView.click(@item.id)

module.exports =
class MenuView extends View
  @content: (item) ->
    @div class: 'menu', =>
      for item in items
        @subview item.id, new MenuItem(item)

  click: (id) ->
    if ! (@find("#menu#{id}").hasClass('inactive'))
      @parentView["#{id}MenuClick"]()

  activate: (type, active) ->
    menuItems = @find(".item.#{type}")
    if active
      menuItems.removeClass('inactive')
    else
      menuItems.addClass('inactive')
    return

  toggleMenuItem: (itemId, active) ->
    menuItem = @find("#menu#{itemId}")
    if active
      menuItem.removeClass('inactive')
    else
      menuItem.addClass('inactive')
    return
