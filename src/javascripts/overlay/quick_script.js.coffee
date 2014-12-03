## QuickScript Extensions

View::showAsModal = (tmp, opts)->
	opts ||= {}
	opts.view = this
	opts.template = tmp
	Overlay.modal(opts)
View::showAsOverlay = View::showAsModal
View::showAsPopover = (el, tmp, opts)->
	opts ||= {}
	opts.view = this
	opts.template = tmp
	Overlay.popover(el, opts)
View::repositionPopover = ->
	$(@overlay_popover_element).trigger 'reposition.overlay.popover'
View::hideOverlay = ->
	@hideModal()
	@hidePopover()
View::hidePopover = ->
	$(@overlay_popover_element).trigger 'hide.overlay.popover' if @overlay_popover_element?
View::hideModal = ->
	$(@overlay_modal_element).trigger 'hide.overlay.modal' if @overlay_modal_element?


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
		#html = ko.bindingHandlers.tip.getContent(element, opts, viewModel)
		content = if opts.template_id?
			"<div data-bind=\"template : '#{opts.template_id}'\"></div>"
		else
			opts.content
		opts.placement ||= 'bottom'
		opts.html = opts.html || opts.template_id? || false
		opts.title ||= content
		opts.container = 'body'
		$(element).tooltip(opts)
		tip = $(element).data('bs.tooltip')
		$tip_el = tip.tip()
		tip.setContent()
		tip.setContent = (content)->		# set content does nothing now
			return if !content?
			tip.options.title = content
			if opts.template_id?
				# do nothing
			else
				$tip_el.find('.tooltip-inner').text(content)
		$tip_el.koBind(viewModel)
		ko.utils.domNodeDisposal.addDisposeCallback element, ->
			$tip_el.koClean()
			tip.destroy()

	update : (element, valueAccessor, bindingsAccessor, viewModel, bindingContext) ->
		opts = ko.unwrap(valueAccessor())
		tip = $(element).data('bs.tooltip')
		tip.setContent(opts.content)


ko.bindingHandlers.loadingOverlay =
	update : (element, valueAccessor) ->
		is_loading = ko.utils.unwrapObservable(valueAccessor())
		if is_loading
			$(element).prepend("<div class='overlay-loading-inline'><img src='#{AssetsLibrary['overlay-spinner']}'/></div>") if $(element).children('.overlay-loading-inline').length == 0
		else
			$(element).children('.overlay-loading-inline').fadeOut('fast', (-> $(this).remove()))

