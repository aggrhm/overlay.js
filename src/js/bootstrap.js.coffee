
Modal = jQuery.fn.modal.Constructor

Modal.prototype.basic_show = Modal.prototype.show

Modal.prototype.show = (_relatedTarget)->
	self = this
	this.basic_show(_relatedTarget)
	# update z-index
	idx = $('.modal.in, .popover').length
	idx = Overlay.utils.availableZIndex()
	if this.$backdrop?
		this.$backdrop.addClass(this.options.className) if this.options.className?
		this.$backdrop.css('z-index', idx - 1)
	this.$element.css('z-index', idx)

	if this.options.attentionAnimation?
		anim = this.options.attentionAnimation
		this.$element.on 'click.dismiss.modal', (ev)->
			return if ev.target != ev.currentTarget
			self.$element.removeClass("animated #{anim}")

			setTimeout ->
				self.$element.addClass("animated #{anim}")
			, 10

# fix body css class
$(document).on 'hidden.bs.modal', '.modal', ->
	setTimeout ->
		if !Overlay.utils.isModalOpen()
			$(document.body).removeClass 'modal-open'
		else
			QS.log 'adding modal class back'
			$(document.body).addClass 'modal-open'
	, 50
