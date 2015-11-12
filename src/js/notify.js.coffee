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


Overlay.toast = (msg, opts={})->
	position = opts.position || 'bottom right'
	padding = opts.padding || 20
	timeout = opts.timeout || 3000
	$toast = $("<div id='overlay-toast' class='overlay-toast animated' style='opacity: 0;'>#{msg}</div>")
	$toast.addClass(opts.className) if opts.className?
	# determine position
	if opts.container?
		$parent = $(opts.container)
		pr = Overlay.utils.getElementPosition(opts.container)
	else
		$parent = $('body')
		$win = $(window)
		ww = $(window).width()
		wh = $(window).height()
		pr = {top: 0, left: 0, width: ww, height: wh, right: ww, bottom: wh}

	$toast.appendTo('body')
	tw = $toast.outerWidth()
	th = $toast.outerHeight()
	
	pos = {}
	if position == 'center'
		pos.left = pr.width / 2 - tw / 2
		pos.top = pr.height / 2 - th / 2
	else
		if position.includes('left')
			pos.left = pr.left + padding
		else
			pos.right = pr.right + padding
		if position.includes('top')
			pos.top = pr.top + padding
		else
			pos.bottom = pr.bottom + padding
	pos['z-index'] = Overlay.utils.availableZIndex($parent[0])
	$toast.css(pos)
	$toast.addClass 'fadeInUp'
	setTimeout ->
		$toast.addClass 'fadeOutDown'
		setTimeout (-> $toast.remove()), 1000
		#console.log 'removing notification'
	, timeout
