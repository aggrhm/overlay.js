## OVERLAY
class @Overlay
	constructor : ->
		@zindex = 100
		@notifyTimer = null
		#$(document).click ->
		#Overlay.removePopovers()
Overlay.instance = new Overlay()
Overlay.templates =
	loading_overlay : (opts)-> "<div class='overlay-spinner-1'></div>"
	notify : (opts)-> "<div class='message'>#{opts.message}</div>"
Overlay.closeDialog = ->
		@remove('dialog')

Overlay.modal = (opts) ->
		vm = opts.view
		tmp = opts.template
		css_opts = opts.style || {}
		cls = opts.className || ''
		id = vm.name
		template = tmp
		#options['z-index'] = Overlay.instance.zindex + 10
		$('#overlay-' + id).remove()
		modal_tpl = "<div id='overlay-#{id}' class='modal fade'><div class='modal-dialog'><div class='modal-content'><button class='close' data-bind='click : hideOverlay'>&times;</button><div class='#{template}' data-bind=\"updateContext : {'$view': $data}, template: '#{template}'\"></div></div></div></div>"
		$modal_el = $(modal_tpl).appendTo('body')
		$modal_dialog = $modal_el.find('.modal-dialog')
		$modal_dialog.css({width : opts.width + 'px'}) if opts.width?
		$modal_dialog.css(css_opts)
		$modal_el.addClass(cls)
		opts.beforeBind?($modal_el)
		#$('#overlay-' + id).css({'margin-left' : -1 * $('#overlay-' + id).width() / 2})
		setTimeout ->
			$modal_el.koBind(vm)
			$modal_el.on 'hidden.bs.modal', (ev)->
				return if ev.target.id != "overlay-#{id}"
				console.log 'Hiding overlay.'
				setTimeout ->
					$modal_el.koClean()
					$modal_el.remove()
				, 100
				vm.hide()
				vm.overlay_modal_element = null
			$modal_el.on 'shown.bs.modal', (ev)->
				return if ev.target.id != "overlay-#{id}"
				vm.show()
				vm.overlay_modal_element = $modal_el[0]
				opts.shown if opts.shown?
			$modal_el.on 'hide.overlay.modal', (ev)->
				$modal_el.modal('hide')

			$modal_el.modal(opts)
		, 100
		#Overlay.instance.zindex = Overlay.instance.zindex + 10
		return $modal_el[0]

Overlay.dialog = (msg, opts) ->
		vm =
			name : 'dialog'
			message : ko.observable(msg)
			yes : opts.yes
			no : opts.no
			cancel : Overlay.remove('dialog')
		Overlay.modal({view: vm, template: 'view-dialog', width : 300 })

Overlay.notify = (msg, type, opts) ->
		opts = opts || {}
		opts.timeout = opts.timeout || 3000
		opts.position = opts.position || 'right'
		opts.message = msg
		opts.type = type = (type || 'info')

		Overlay.clearNotifications()
		$('body').prepend("<div id='overlay-notify' class='overlay-notify #{type} p-#{opts.position}' style='display: none;'>#{Overlay.templates.notify(opts)}</div>")
		$notif = $('#overlay-notify')
		$notif.addClass(opts.css) if (opts.css?)
		$notif.fadeIn 'slow', ->
			Overlay.instance.notifyTimeout = setTimeout ->
				$notif.fadeOut('slow')
				#console.log 'removing notification'
			, opts.timeout

Overlay.clearNotifications = ->
		clearTimeout(Overlay.instance.notifyTimeout)
		$('#overlay-notify').remove()

Overlay.confirm = (msg, opts) ->
		opts.title ||= "Continue?"
		vm =
			message : msg
			title : opts.title
			yes : ->
				$('#overlay-confirm').modal('hide')
				opts.yes() if opts.yes?
			no : ->
				$('#overlay-confirm').modal('hide')
				opts.no() if opts.no?
			yes_text : opts.yes_text || "Yes"
			no_text : opts.no_text || "No"
		tmp = "
			<div id='overlay-confirm' class='modal fade'>
				<div class='modal-dialog'>
					<div class='modal-content'>
						<div class='modal-header'><h4 class='modal-title' data-bind='text : title'></h4></div>
						<div class='modal-body' data-bind='text : message'></div>
						<div class='modal-footer'><button class='btn btn-default' data-bind='click : no, html : no_text'>No</button><button class='btn btn-success' data-bind='click : yes, html : yes_text'>Yes</button></div>
					</div>
				</div>
			</div>
			"
		$modal = $('#overlay-confirm')
		if $modal.length == 0
			$modal = $(tmp)
			$modal.appendTo('body')
		else
			$modal.koClean()
			$modal.removeClass('animated shake')
		$modal.koBind(vm)
		$modal.modal
			backdrop : 'static'
			attentionAnimation : 'shake'

Overlay.alert = (msg, opts) ->
		opts ||= {}
		opts.title ||= "Alert!"
		vm =
			message : msg
			title : opts.title
			ok : ->
				$('#overlay-alert').modal('hide')
				opts.ok() if opts.ok?
		tmp = "
			<div id='overlay-alert' class='modal fade'>
				<div class='modal-dialog'>
					<div class='modal-content'>
						<div class='modal-header'><h4 class='modal-title' data-bind='text : title'></h4></div>
						<div class='modal-body' style='font-size: 20px;' data-bind='text : message'></div>
						<div class='modal-footer'><button class='btn btn-primary' data-bind='click : ok'>OK</button></div>
					</div>
				</div>
			</div>
			"
		$modal = $('#overlay-alert')
		if $modal.length == 0
			$modal = $(tmp)
			$modal.appendTo('body')
		else
			$modal.koClean()
		$modal.koBind(vm)
		$modal.modal
			backdrop : 'static'
			attentionAnimation : 'shake'

Overlay.remove = (id) ->
	Overlay.removeModal(id)
	Overlay.removePopover(id)

Overlay.removeModal = (id) ->
	$('#overlay-' + id).trigger('hide.overlay.modal')

Overlay.removePopover = (id) ->
	$po = $("#popover-#{id}")
	$po.trigger 'hide.overlay.popover'

Overlay.removePopovers = ->
	$('.popover').each ->
		$(this).trigger 'hide.overlay.popover'

Overlay.repositionPopover = (id)->
	Overlay.utils.positionPopover( $("#popover-#{id}") )

Overlay.isVisible = (id) ->
	$('#overlay-' + id).length > 0

Overlay.show_loading = ->
	$overlay = $("#overlay-loading-screen")
	$overlay.remove()
	tpl = "<div id='overlay-loading-screen' class='overlay-loading-screen'><div class='progress progress-striped active'><div class='progress-bar' style='width: 100%'></div></div></div>"
	$overlay = $(tpl)
	$overlay.appendTo("body").fadeIn()
Overlay.hide_loading = ->
	$overlay = $("#overlay-loading-screen")
	$overlay.fadeOut
		complete: ->
			$overlay.remove()

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
	$po = $("
		<div id='popover-#{id}' class='popover fade'>
			<div class='arrow'></div>
			<div class='popover-inner'>
				<button class='close' data-bind='click : hidePopover'>&times;</button>
				<div class='#{tmp}' data-bind=\"updateContext : {'$view': $data}, template : '#{tmp}'\"></div>
			</div>
		</div>
	")
	$backdrop = $("<div class='popover-backdrop'></div>")

	container = if opts.container == 'parent'
		$(el).parent()
	else
		document.body
	setTimeout ->
		zidx = Overlay.utils.availableZIndex()
		$po.remove().css({ top: 0, left: 0, display: 'block', width: opts.width, height: opts.height, 'z-index': zidx }).prependTo(container)
		if opts.backdrop
			$backdrop.css({'z-index': zidx-1})
			$backdrop.click ->
				$po.trigger('hide.overlay.popover')
			$backdrop.prependTo(document.body)
			opts.$backdrop = $backdrop
		$po.css(opts.style) if opts.style?
		$po.attr('data-bind', opts.binding) if opts.binding?
		$po.koBind(vm)
		vm.overlay_popover_element = $po[0]
		vm.show()
		$po.click (ev)->
			ev.stopPropagation()
		$po.on 'hide.overlay.popover', ->
			vm.hide()
			vm.overlay_popover_element = null
			$po.koClean().remove()
			$backdrop.remove()
		$po.on 'reposition.overlay.popover', ->
			Overlay.utils.positionPopover($po)

		$po.data('overlay.popover', opts)
		Overlay.utils.positionPopover($po)
	, 100
	return $po[0]

Overlay.utils = {
	getElementPosition: (el)->
		ret = $(el).offset()
		ret.width = el.offsetWidth
		ret.height = el.offsetHeight
		return ret
	availableZIndex : ->
		idx = $('.modal.in, .popover').length
		return 1040 + (idx * 10)
	positionPopover : ($po)->
		return if $po.length == 0
		$arrow = $po.find('.arrow')
		opts = $po.data('overlay.popover')
		anchor = opts.anchor
		anchor_pos = Overlay.utils.getElementPosition(anchor)
		an_t = anchor_pos.top
		an_l = anchor_pos.left
		an_w = anchor_pos.width
		an_h = anchor_pos.height
		po_w = $po[0].offsetWidth
		po_h = $po[0].offsetHeight
		win_w = $(window).width()
		win_h = $(window).height()
		top = 0
		left = 0

		# try placements
		placement = null
		for pl in opts.placement.split(' ')
			placement = pl
			switch (pl)
				when 'bottom'
					top = an_t + an_h
					left = an_l + an_w / 2 - po_w / 2
				when 'top'
					top = an_t - po_h
					left = an_l + an_w / 2 - po_w / 2
				when 'left'
					left = an_l - po_w
					if opts.top == 'center'
						top = an_t + an_h / 2 - po_h / 2
					else
						top = an_t + opts.top
				when 'right'
					left = an_l + an_w
					if opts.top == 'center'
						top = an_t + an_h / 2 - po_h / 2
					else
						top = an_t + opts.top
			
			# check metrics
			if pl == 'right' && (left + po_w) > win_w
				continue
			if pl == 'left' && (left < 0)
				continue
			else
				break
			
		# fix top
		if top < 0
			top = 0
		else if top + po_h > win_h
			top = win_h - po_h
		# fix left
		left = 0 if left < 0
		
		$po.offset({top: top, left: left}).addClass(placement).addClass('in')
		ao_t = top - an_t
		if opts.top != 'center'
			$arrow.css({top: Math.abs(ao_t) + an_h / 2})
}
	
