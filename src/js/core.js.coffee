## OVERLAY
class @Overlay
	constructor : ->
		@zindex = 100
		@notifyTimer = null
		#$(document).click ->
		#Overlay.removePopovers()
Overlay.instance = new Overlay()
Overlay.eventListeners = {}
Overlay.templates =
	loading_overlay : (opts)-> "<div class='overlay-spinner-1'></div>"
	notify : (opts)-> "<div class='message'>#{opts.message}</div>"
	modal_close_button_content: "&times;"

Overlay.remove = (id) ->
	Overlay.removeModal(id)
	Overlay.removePopover(id)

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

Overlay.addEventListener = (ev, listener)->
	lm = Overlay.eventListeners
	lm[ev] ||= []
	lm[ev].push(listener)

Overlay.removeEventListener = (ev, listener)->
	lm = Overlay.eventListeners
	return false if !lm[ev]?
	idx = lm[ev].indexOf(listener)
	if idx > -1
		lm[ev].splice(idx, 1)
		return true
	else
		return false

Overlay.dispatchEvent = (ev, data)->
	lm = Overlay.eventListeners
	return if !lm[ev]?
	for l in lm[ev]
		l(data)


Overlay.utils = {
	getElementPosition: (el)->
		if el.getBoundingClientRect?
			rect = el.getBoundingClientRect()
			ret = {width: rect.width, height: rect.height, top: rect.top, left: rect.left, bottom: rect.bottom, right: rect.right}
		else
			ret = $(el).offset()
			ret.width = el.offsetWidth
			ret.height = el.offsetHeight
			ret.right = ret.left + ret.width
			ret.bottom = ret.top + ret.height
		return ret
	lastGlobalZIndex : 2000
	availableZIndex : (el)->
		if !el?
			#idx = $('.modal.in, .popover').length
			#return 2000 + (idx * 10)
			ret = Overlay.utils.lastGlobalZIndex
			Overlay.utils.lastGlobalZIndex += 10
			return ret
		else
			# determine largest z-index of parents
			vals = $(el).parents().map ->
				val = parseInt($(this).css('z-index'))
				return if isNaN(val) then 0 else val
			return Math.max.apply(null, vals) + 10
	isModalOpen : ->
		$('.modal.in').length > 0
	positionPopover : ($po)->
		return if $po.length == 0
		$arrow = $po.find('.arrow')
		opts = $po.data('overlay.popover')
		anchor = opts.anchor
		$container = opts.$container
		anchor_pos = Overlay.utils.getElementPosition(anchor)
		an_t = anchor_pos.top
		an_l = anchor_pos.left
		an_w = anchor_pos.width
		an_h = anchor_pos.height
		po_w = $po[0].offsetWidth
		po_h = $po[0].offsetHeight
		win_rect = Overlay.utils.getElementPosition(opts.$container[0])
		screen_height = $(window).height()
		if opts.container == 'body' && screen_height > win_rect.height
			win_rect.height = screen_height
			win_rect.bottom = screen_height

		#QS.log "w = #{win_w} h = #{win_h}"
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
					if opts.top?
						top = an_t + opts.top
					else
						top = an_t + an_h / 2 - po_h / 2
				when 'right'
					left = an_l + an_w
					if opts.top?
						top = an_t + opts.top
					else
						top = an_t + an_h / 2 - po_h / 2
			
			# check metrics
			if (left + po_w) > win_rect.right # too far right
				continue
			if (left < 0)	# too far left
				continue
			if top < win_rect.top	# too far up
				continue
			if (top + po_h) > win_rect.bottom	# too far down
				continue
			else
				break
			
		$po.offset({top: top, left: left}).addClass(placement).addClass('in')
}
