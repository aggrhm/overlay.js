## QuickScript Extensions

QS.View::showAsModal = (tmp, opts)->
	opts ||= {}
	opts.view = this
	opts.template = tmp
	Overlay.modal(opts)
QS.View::showAsOverlay = QS.View::showAsModal
QS.View::showAsPopover = (el, tmp, opts)->
	opts ||= {}
	opts.view = this
	opts.template = tmp
	Overlay.popover(el, opts)
QS.View::repositionPopover = ->
	$(@overlay_popover_element).trigger 'reposition.overlay.popover'
QS.View::hideOverlay = ->
	@hideModal()
	@hidePopover()
QS.View::hidePopover = ->
	$(@overlay_popover_element).trigger 'hide.overlay.popover' if @overlay_popover_element?
QS.View::hideModal = ->
	$(@overlay_modal_element).trigger 'hide.overlay.modal' if @overlay_modal_element?
QS.View::showToast = (msg, opts={})->
	opts.container ||= @element
	Overlay.toast(msg, opts)


# popover : {template : <tmp>, placement : <pos>}
ko.bindingHandlers.popover =
	init : (element, valueAccessor, bindingsAccessor, viewModel) ->
		opts = valueAccessor()
		opts.view ||= viewModel
		$(element).click ->
			Overlay.popover element, opts

# tip : {content : <content>, ...}
ko.bindingHandlers.tip =
	init : (element, valueAccessor, bindingsAccessor, viewModel, bindingContext) ->
		opts = ko.unwrap(valueAccessor())
		$el = $(element)
		#html = ko.bindingHandlers.tip.getContent(element, opts, viewModel)
		buildTip = ->
			content = if opts.template_id?
				"<div data-bind=\"template : '#{opts.template_id}'\"></div>"
			else
				opts.content
			opts.placement ||= 'bottom'
			opts.html = opts.html || opts.template_id? || false
			opts.title ||= content
			opts.container ||= 'body'
			$el.tooltip(opts)
			tip = $el.data('bs.tooltip')
			$tip_el = tip.tip()
			$tip_el.addClass(opts.className) if opts.className?
			tip.setContent()
			tip.setContent = (content)->		# set content does nothing now
				return if !content?
				tip.options.title = content
				if opts.template_id?
					# do nothing
				else
					etfn = if (opts.html == true) then 'html' else 'text'
					$tip_el.find('.tooltip-inner')[etfn](content)
			$tip_el.koBind(viewModel)
			tip.show()
			ko.utils.domNodeDisposal.addDisposeCallback element, ->
				$tip_el.koClean()
				tip.destroy()
		$el.on 'mouseover', ->
			buildTip() unless $el.data('bs.tooltip')?
		ko.utils.domNodeDisposal.addDisposeCallback element, ->
			$el.off('mouseover')
	update : (element, valueAccessor, bindingsAccessor, viewModel, bindingContext) ->
		opts = ko.unwrap(valueAccessor())
		tip = $(element).data('bs.tooltip')
		if tip?
			tip.setContent(opts.content)


ko.bindingHandlers.loadingOverlay =
	update : (element, valueAccessor) ->
		$el = $(element)
		is_loading = ko.utils.unwrapObservable(valueAccessor())
		if is_loading
			if $el.children('.overlay-loading-inline').length == 0
				$el.prepend("<div class='overlay-loading-inline'>#{Overlay.templates.loading_overlay()}</div>")
			else
				$el.children('.overlay-loading-inline').stop().show()
		else
			$(element).children('.overlay-loading-inline').fadeOut('fast')

