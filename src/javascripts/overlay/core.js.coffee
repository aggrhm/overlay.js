## OVERLAY
class @Overlay
	constructor : ->
		@zindex = 100
		@notifyTimer = null
		$(document).click ->
			Overlay.removePopovers()
Overlay.instance = new Overlay()
Overlay.closeDialog = ->
		@remove('dialog')
Overlay.add = (vm, tmp, opts) ->
		opts ||= {}
		css_opts = opts.style || {}
		cls = opts.className || ''
		id = vm.name
		template = tmp
		#options['z-index'] = Overlay.instance.zindex + 10
		$('#overlay-' + id).remove()
		$('body').append("<div id='overlay-#{id}' class='modal hide fade'><button class='close' data-bind='click : hideOverlay'>x</button><div class='content #{template}' data-bind=\"template: '#{template}'\"></div></div>")
		$('#overlay-' + id).css(css_opts)
		$('#overlay-' + id).addClass(cls)
		#$('#overlay-' + id).css({'margin-left' : -1 * $('#overlay-' + id).width() / 2})
		setTimeout ->
			$('#overlay-' + id).koBind(vm)
			#if opts.stretch == true
				#$("#overlay-#{id} .modal-body").css({'max-height' : ($(window).height() - 200)})
				#$('#overlay-' + id).css({'margin-top' : ($(window).height() - 100)/ -2})
			$('#overlay-' + id).on 'hidden', (ev)->
				return if ev.target.id != "overlay-#{id}"
				console.log 'Hiding overlay.'
				setTimeout ->
					$('#overlay-' + id).koClean()
					$('#overlay-' + id).remove()
				, 100
				vm.onHidden() if vm.onHidden?
				opts.hidden() if opts.hidden
			$('#overlay-' + id).on 'shown', (ev)->
				return if ev.target.id != "overlay-#{id}"
				vm.onShown(ev.target) if vm.onShown?
				opts.shown if opts.shown?
			$('#overlay-' + id).modal(opts)
		, 100
		#Overlay.instance.zindex = Overlay.instance.zindex + 10

Overlay.dialog = (msg, opts) ->
		vm =
			name : 'dialog'
			message : ko.observable(msg)
			yes : opts.yes
			no : opts.no
			cancel : Overlay.remove('dialog')
		Overlay.add(vm, 'view-dialog', { width : 300 })

Overlay.notify = (msg, type, opts) ->
		opts = opts || {}
		opts.timeout = opts.timeout || 3000
		opts.position = opts.position || 'right'
		type = type || 'info'

		Overlay.clearNotifications()
		$('body').prepend("<div id='qs-notify' class='qs-notify-elegant #{type} p-#{opts.position}' style='display: none;'><img class='icon' src='#{AssetsLibrary['overlay-notify']}'/><div class='title'>#{msg}</div></div>")
		$notif = $('#qs-notify')
		$notif.addClass(opts.css) if (opts.css?)
		$notif.fadeIn 'slow', ->
			Overlay.instance.notifyTimeout = setTimeout ->
				$notif.fadeOut('slow')
				#console.log 'removing notification'
			, opts.timeout

Overlay.clearNotifications = ->
		clearTimeout(Overlay.instance.notifyTimeout)
		$('#qs-notify').remove()

Overlay.confirm = (msg, opts) ->
		vm =
			message : msg
			yes : ->
				$('#qs-overlay-confirm').modal('hide')
				opts.yes() if opts.yes?
			no : ->
				$('#qs-overlay-confirm').modal('hide')
				opts.no() if opts.no?
		tmp = "<div id='qs-overlay-confirm' class='modal hide fade'><div class='modal-header'><h4>Continue?</h4></div><div class='modal-body' style='font-size: 20px;' data-bind='text : message'></div><div class='modal-footer'><button class='btn btn-danger' data-bind='click : no'>No</button><button class='btn btn-success' data-bind='click : yes'>Yes</button></div></div>"
		$modal = $('#qs-overlay-confirm')
		if $modal.length == 0
			$modal = $(tmp)
			$modal.appendTo('body')
		else
			$modal.koClean()
		$modal.koBind(vm)
		$modal.modal
			backdrop : 'static'
			attentionAnimation : 'shake'

Overlay.alert = (msg, opts) ->
		opts ||= {}
		vm =
			message : msg
			ok : ->
				$('#qs-overlay-alert').modal('hide')
				opts.ok() if opts.ok?
		tmp = "<div id='qs-overlay-alert' class='modal hide fade'><div class='modal-header'><h4>Alert!</h4></div><div class='modal-body' style='font-size: 20px;' data-bind='text : message'></div><div class='modal-footer'><button class='btn btn-primary' data-bind='click : ok'>OK</button></div></div>"
		$modal = $('#qs-overlay-alert')
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
	$('#overlay-' + id).modal('hide')
	$('#backdrop-' + id).remove()
	$('#overlay-' + id).remove() if (id == 'confirm')

Overlay.removePopover = (id) ->
	$('#popover-' + id).koClean().remove()

Overlay.removePopovers = ->
		$('.popover').remove()

Overlay.isVisible = (id) ->
		$('#overlay-' + id).length > 0

Overlay.show_loading = ->
	$('body').modalmanager('loading')
Overlay.hide_loading = ->
	$('body').modalmanager('loading')

Overlay.popover = (el, vm, tmp, opts)->
	id = vm.name
	opts.placement = opts.placement || 'bottom'
	$po = $("<div id='popover-#{id}' class='popover fade'><div class='arrow'></div><div class='popover-inner'><button class='close' data-bind='click : hidePopover'>x</button><h3 class='popover-title'>#{opts.title}</h3><div class='popover-content' data-bind=\"template : '#{tmp}'\"></div></div></div>")

	setTimeout ->
		$po.remove().css({ top: 0, left: 0, display: 'block', width: 'auto' }).prependTo(document.body)
		$po.koBind(vm)
		$po.click (ev)->
			ev.stopPropagation()

		pos = getElementPosition(el)
		actualWidth = $po[0].offsetWidth
		actualHeight = $po[0].offsetHeight
		#console.log(actualWidth + ' ' + actualHeight)
		#console.log(pos)

		switch (opts.placement)
			when 'bottom'
				tp = {top: pos.top + pos.height, left: pos.left + pos.width / 2 - actualWidth / 2}
			when 'top'
				tp = {top: pos.top - actualHeight, left: pos.left + pos.width / 2 - actualWidth / 2}
			when 'left'
				tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left - actualWidth}
			when 'right'
				tp = {top: pos.top + pos.height / 2 - actualHeight / 2, left: pos.left + pos.width}

		tp.top = 0 if tp.top < 0
		tp.left = 0 if tp.left < 0

		tp.display = 'block'
		$po.css(opts.style) if opts.style?
		$po.css(tp).addClass(opts.placement).addClass('in')
	, 100

