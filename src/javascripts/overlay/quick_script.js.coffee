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
	

ko.bindingHandlers.loadingOverlay =
	update : (element, valueAccessor) ->
		is_loading = ko.utils.unwrapObservable(valueAccessor())
		if is_loading
			$(element).prepend("<div class='overlay-loading-inline'><img src='#{AssetsLibrary['overlay-spinner']}'/></div>") if $(element).children('.overlay-loading-inline').length == 0
		else
			$(element).children('.overlay-loading-inline').fadeOut('fast', (-> $(this).remove()))

