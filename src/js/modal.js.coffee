Overlay.modal = (opts) ->
		vm = opts.view
		tmp = opts.template
		css_opts = opts.style || {}
		cls = opts.className || ''
		id = vm.name
		template = tmp
		add_close = opts.showCloseButton != false
		close_btn_html = opts.close_button_content || opts.closeButtonContent || Overlay.templates.modal_close_button_content || Overlay.templates.modalCloseButtonContent
		#options['z-index'] = Overlay.instance.zindex + 10
		$('#overlay-' + id).remove()
		if opts.containerTemplate?
			modal_tpl = opts.containerTemplate
		else
			modal_tpl = "<div class='modal fade'><div class='modal-dialog'><div class='modal-content'>"
			if add_close
				modal_tpl += "<button class='modal-default-close close' data-bind='click : hideOverlay'>#{close_btn_html}</button>"
			modal_tpl += "<div class='modal-content-body #{template}' data-bind=\"updateContext : {'$view': $data}, template: '#{template}'\"></div></div></div></div>"
		$modal_el = $(modal_tpl).appendTo('body')
		$modal_dialog = $modal_el.find('.modal-dialog')
		$modal_dialog.css({width : opts.width + 'px'}) if opts.width?
		$modal_dialog.css(css_opts)
		$modal_el.addClass(cls)
		$modal_el.attr('id', "overlay-#{id}")
		opts.beforeBind?($modal_el)
		#$('#overlay-' + id).css({'margin-left' : -1 * $('#overlay-' + id).width() / 2})
		setTimeout ->
			root_context = ko.contextFor($('body')[0])
			context = root_context.createChildContext(vm, '$view')
			$modal_el.koBind(context)
			$modal_el.on 'hidden.bs.modal', (ev)->
				return if ev.target.id != "overlay-#{id}"
				console.log 'Hiding overlay.'
				setTimeout ->
					$modal_el.koClean()
					$modal_el.remove()
					Overlay.dispatchEvent("modal_hidden", {view: vm})
				, 100
				vm.hide()
				vm.overlay_modal_element = null
			$modal_el.on 'shown.bs.modal', (ev)->
				return if ev.target.id != "overlay-#{id}"
				vm.show()
				vm.overlay_modal_element = $modal_el[0]
				opts.shown if opts.shown?
				Overlay.dispatchEvent("modal_shown", {view: vm})
			$modal_el.on 'hide.overlay.modal', (ev)->
				$modal_el.modal('hide')

			$modal_el.modal(opts)
		, 100
		#Overlay.instance.zindex = Overlay.instance.zindex + 10
		return $modal_el[0]

Overlay.removeModal = (id) ->
	$('#overlay-' + id).trigger('hide.overlay.modal')


Overlay.dialog = (msg, opts) ->
		vm =
			name : 'dialog'
			message : ko.observable(msg)
			yes : opts.yes
			no : opts.no
			cancel : Overlay.remove('dialog')
		Overlay.modal({view: vm, template: 'view-dialog', width : 300 })


Overlay.closeDialog = ->
		@remove('dialog')

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
						<div class='modal-body' data-bind='html : message'></div>
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
						<div class='modal-body' data-bind='html : message'></div>
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

