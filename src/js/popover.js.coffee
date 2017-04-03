Overlay.popover = (el, opts)->
	vm = opts.view
	tmp = opts.template
	id = vm.name
	opts.placement ||= 'right'
	opts.title ||= 'Options'
	opts.width ||= 'auto'
	opts.height ||= 'auto'
	opts.container ||= 'body'
	opts.top ||= -40
	opts.left ||= -40
	opts.anchor = el
	if opts.containerTemplate?
		$po = $(opts.containerTemplate)
	else
		$po = $("
			<div class='popover fade'>
				<div class='arrow'></div>
				<div class='popover-inner'>
					<button class='close' data-bind='click : hidePopover'>&times;</button>
					<div class='#{tmp}' data-bind=\"updateContext : {'$view': $data}, template : '#{tmp}'\"></div>
				</div>
			</div>
		")
	$po.attr('id', "popover-#{id}")
	$backdrop = $("<div class='popover-backdrop'></div>")

	container = if opts.container == 'parent'
		$(el).parent()
	else
		$(opts.container)
	opts.$container = container
	setTimeout ->
		zidx = Overlay.utils.availableZIndex(el)
		$po.remove().css({ top: 0, left: 0, display: 'block', width: opts.width, height: opts.height, 'z-index': zidx }).prependTo(container)
		if opts.backdrop
			$backdrop.css({'z-index': zidx-1})
			$backdrop.click ->
				$po.trigger('hide.overlay.popover')
			$backdrop.prependTo(document.body)
			opts.$backdrop = $backdrop
		$po.css(opts.style) if opts.style?
		$po.addClass(opts.className) if opts.className?
		$po.attr('data-bind', opts.binding) if opts.binding?
		$po.koBind(vm)
		vm.overlay_popover_element = $po[0]
		vm.overlay_anchor_element = el
		vm.show()
		$po.click (ev)->
			ev.stopPropagation()
		$po.on 'hide.overlay.popover', ->
			vm.hide()
			vm.overlay_popover_element = null
			vm.overlay_anchor_element = null
			$po.koClean().remove()
			$backdrop.remove()
		$po.on 'reposition.overlay.popover', ->
			Overlay.utils.positionPopover($po)

		$po.data('overlay.popover', opts)
		Overlay.utils.positionPopover($po)
	, 100
	return $po[0]


Overlay.removePopover = (id) ->
	$po = $("#popover-#{id}")
	$po.trigger 'hide.overlay.popover'

Overlay.removePopovers = ->
	$('.popover').each ->
		$(this).trigger 'hide.overlay.popover'

Overlay.repositionPopover = (id)->
	Overlay.utils.positionPopover( $("#popover-#{id}") )

