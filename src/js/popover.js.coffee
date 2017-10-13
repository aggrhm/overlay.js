Overlay.popover = (el, opts)->
  vm = opts.view
  tmp = opts.template
  id = vm.name
  opts.placement ||= 'bottom'
  opts.width ||= 'auto'
  opts.height ||= 'auto'
  opts.container ||= 'body'
  opts.closeOnOutsideClick = true if !opts.closeOnOutsideClick?
  opts.preventOutsideClick ||= false
  opts.popperOptions ||= {}
  opts.anchor = el
  add_close = opts.showCloseButton != false

  # set template
  if opts.containerTemplate?
    po = opts.containerTemplate
  else
    po = "<div class='popover popper'>"
    if add_close
      po += "<button class='close' data-bind='click : hidePopover'>&times;</button>"
    po += "<div class='popover-arrow popper__arrow' x-arrow></div>"
    po += "<div class='popover-inner'><div class='#{tmp}' data-bind=\"updateContext : {'$view': $data}, template : '#{tmp}'\"></div></div>"
    po += "</div>"
  $po = $(po)
  $arrow = $po.find('.popover-arrow')
  opts.popover_element = popover_element = $po[0]
  $po.attr('id', "popover-#{id}")

  # set container
  container = if opts.container == 'parent'
    $(el).parent()
  else
    $(opts.container)
  opts.$container = container

  setTimeout ->
    # init element
    $po.remove().css({display: 'block', width: opts.width, height: opts.height}).prependTo(container)
    $po.css(opts.style) if opts.style?
    $po.addClass(opts.className) if opts.className?
    $po.attr('data-bind', opts.binding) if opts.binding?
    $po.koBind(vm)

    # events

    outside_click_fn = (ev)->
      $target = $(ev.target)
      if ev.target != popover_element && !popover_element.contains(ev.target)
        if opts.closeOnOutsideClick == true
          $po.trigger 'hide.overlay.popover'
        if opts.preventOutsideClick == true
          ev.stopPropagation?()

    $po.on 'hide.overlay.popover', ->
      vm.hide()
      popper = vm.overlay_popover_options.popper
      popper.destroy()
      vm.overlay_popover_element = null
      vm.overlay_popover_options = null
      $po.koClean().remove()
      $(document).off 'mousedown touchstart', outside_click_fn


    # popper init
    popts = {
      placement: opts.placement
      removeOnDestroy: false
      onCreate: ->
        vm.overlay_popover_element = opts.popover_element
        vm.overlay_popover_options = opts
        if opts.closeOnOutsideClick == true
          $(document).on 'mousedown touchstart', outside_click_fn
        vm.show()
    }
    $.extend(popts, opts.popperOptions)
    opts.popper = new Popper(el, opts.popover_element, popts)
  , 50
  return $po[0]


Overlay.removePopover = (id) ->
  $po = $("#popover-#{id}")
  $po.trigger 'hide.overlay.popover'

Overlay.removePopovers = ->
  $('.popover').each ->
    $(this).trigger 'hide.overlay.popover'

