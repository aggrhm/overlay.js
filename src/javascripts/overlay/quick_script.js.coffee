## QuickScript Extensions

View::showAsOverlay = (tmp, opts, cls)->
		Overlay.add(this, tmp, opts, cls)
View::showAsPopover = (el, tmp, opts)->
		Overlay.popover(el, this, tmp, opts)
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
		$(element).click ->
			Overlay.popover element, viewModel, opts.template, opts
	

ko.bindingHandlers.loadingOverlay =
	update : (element, valueAccessor) ->
		is_loading = ko.utils.unwrapObservable(valueAccessor())
		if is_loading
			$(element).prepend("<div class='loading-overlay'><img src='#{AssetsLibrary['spinner']}'/></div>") if $(element).children('.loading-overlay').length == 0
		else
			$(element).children('.loading-overlay').fadeOut('fast', (-> $(this).remove()))

