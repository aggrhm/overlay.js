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

Overlay.utils = {
	getElementPosition: (el)->
		ret = $(el).offset()
		ret.width = el.offsetWidth
		ret.height = el.offsetHeight
		ret.right = ret.left + ret.width
		ret.bottom = ret.top + ret.height
		return ret
	availableZIndex : (el)->
		if !el?
			idx = $('.modal.in, .popover').length
			return 2000 + (idx * 10)
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
		if opts.container == 'body' && $(window).height() > win_rect.height
			win_rect.height = $(window).height()
			win_rect.bottom = win_rect.height

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
			if pl == 'right' && (left + po_w) > win_rect.right
				continue
			if pl == 'left' && (left < 0)
				continue
			else
				break
			
		# fix top
		if top < win_rect.top
			top = win_rect.top
		else if top + po_h > win_rect.bottom
			top = win_rect.bottom - po_h
		# fix left
		left = win_rect.left if left < win_rect.left
		
		$po.offset({top: top, left: left}).addClass(placement).addClass('in')
		ao_t = top - an_t
		if opts.top != 'center'
			$arrow.css({top: Math.abs(ao_t) + an_h / 2})
}
