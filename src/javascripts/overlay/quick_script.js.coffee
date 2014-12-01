## QuickScript Extensions

View::showAsOverlay = (tmp, opts)->
	opts ||= {}
	opts.view = this
	opts.template = tmp
	Overlay.modal(opts)
View::showAsPopover = (el, tmp, opts)->
	opts ||= {}
	opts.view = this
	opts.template = tmp
	Overlay.popover(el, opts)
View::repositionPopover = ->
	Overlay.repositionPopover( @name )
View::hideOverlay = ->
	Overlay.remove(@name)
View::hidePopover = ->
	Overlay.removePopover(@name)
View::overlayVisible = ->
	Overlay.isVisible(@name)


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
			opts.text || opts.content
		opts.placement ||= 'bottom'
		opts.html = opts.html || opts.template_id? || false
		opts.title ||= content
		opts.container = 'body'
		$(element).tooltip(opts)
		tip = $(element).data('bs.tooltip')
		$tip_el = tip.tip()
		tip.setContent()
		tip.setContent = ->		# set content does nothing now
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
		tip.setContent()


ko.bindingHandlers.loadingOverlay =
	update : (element, valueAccessor) ->
		is_loading = ko.utils.unwrapObservable(valueAccessor())
		if is_loading
			$(element).prepend("<div class='overlay-loading-inline'><img src='#{AssetsLibrary['overlay-spinner']}'/></div>") if $(element).children('.overlay-loading-inline').length == 0
		else
			$(element).children('.overlay-loading-inline').fadeOut('fast', (-> $(this).remove()))

