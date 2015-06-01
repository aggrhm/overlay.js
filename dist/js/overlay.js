(function() {
  this.Overlay = (function() {
    function Overlay() {
      this.zindex = 100;
      this.notifyTimer = null;
    }

    return Overlay;

  })();

  Overlay.instance = new Overlay();

  Overlay.templates = {
    loading_overlay: function(opts) {
      return "<div class='overlay-spinner-1'></div>";
    },
    notify: function(opts) {
      return "<div class='message'>" + opts.message + "</div>";
    }
  };

  Overlay.closeDialog = function() {
    return this.remove('dialog');
  };

  Overlay.modal = function(opts) {
    var $modal_dialog, $modal_el, cls, css_opts, id, modal_tpl, template, tmp, vm;
    vm = opts.view;
    tmp = opts.template;
    css_opts = opts.style || {};
    cls = opts.className || '';
    id = vm.name;
    template = tmp;
    $('#overlay-' + id).remove();
    modal_tpl = "<div id='overlay-" + id + "' class='modal fade'><div class='modal-dialog'><div class='modal-content'><button class='close' data-bind='click : hideOverlay'>&times;</button><div class='" + template + "' data-bind=\"updateContext : {'$view': $data}, template: '" + template + "'\"></div></div></div></div>";
    $modal_el = $(modal_tpl).appendTo('body');
    $modal_dialog = $modal_el.find('.modal-dialog');
    if (opts.width != null) {
      $modal_dialog.css({
        width: opts.width + 'px'
      });
    }
    $modal_dialog.css(css_opts);
    $modal_el.addClass(cls);
    setTimeout(function() {
      $modal_el.koBind(vm);
      $modal_el.on('hidden.bs.modal', function(ev) {
        if (ev.target.id !== ("overlay-" + id)) {
          return;
        }
        console.log('Hiding overlay.');
        setTimeout(function() {
          $modal_el.koClean();
          return $modal_el.remove();
        }, 100);
        vm.hide();
        return vm.overlay_modal_element = null;
      });
      $modal_el.on('shown.bs.modal', function(ev) {
        if (ev.target.id !== ("overlay-" + id)) {
          return;
        }
        vm.show();
        vm.overlay_modal_element = $modal_el[0];
        if (opts.shown != null) {
          return opts.shown;
        }
      });
      $modal_el.on('hide.overlay.modal', function(ev) {
        return $modal_el.modal('hide');
      });
      return $modal_el.modal(opts);
    }, 100);
    return $modal_el[0];
  };

  Overlay.dialog = function(msg, opts) {
    var vm;
    vm = {
      name: 'dialog',
      message: ko.observable(msg),
      yes: opts.yes,
      no: opts.no,
      cancel: Overlay.remove('dialog')
    };
    return Overlay.modal({
      view: vm,
      template: 'view-dialog',
      width: 300
    });
  };

  Overlay.notify = function(msg, type, opts) {
    var $notif;
    opts = opts || {};
    opts.timeout = opts.timeout || 3000;
    opts.position = opts.position || 'right';
    opts.message = msg;
    opts.type = type = type || 'info';
    Overlay.clearNotifications();
    $('body').prepend("<div id='overlay-notify' class='overlay-notify " + type + " p-" + opts.position + "' style='display: none;'>" + (Overlay.templates.notify(opts)) + "</div>");
    $notif = $('#overlay-notify');
    if ((opts.css != null)) {
      $notif.addClass(opts.css);
    }
    return $notif.fadeIn('slow', function() {
      return Overlay.instance.notifyTimeout = setTimeout(function() {
        return $notif.fadeOut('slow');
      }, opts.timeout);
    });
  };

  Overlay.clearNotifications = function() {
    clearTimeout(Overlay.instance.notifyTimeout);
    return $('#overlay-notify').remove();
  };

  Overlay.confirm = function(msg, opts) {
    var $modal, tmp, vm;
    opts.title || (opts.title = "Continue?");
    vm = {
      message: msg,
      title: opts.title,
      yes: function() {
        $('#overlay-confirm').modal('hide');
        if (opts.yes != null) {
          return opts.yes();
        }
      },
      no: function() {
        $('#overlay-confirm').modal('hide');
        if (opts.no != null) {
          return opts.no();
        }
      },
      yes_text: opts.yes_text || "Yes",
      no_text: opts.no_text || "No"
    };
    tmp = "<div id='overlay-confirm' class='modal fade'> <div class='modal-dialog'> <div class='modal-content'> <div class='modal-header'><h4 class='modal-title' data-bind='text : title'></h4></div> <div class='modal-body' data-bind='text : message'></div> <div class='modal-footer'><button class='btn btn-default' data-bind='click : no, html : no_text'>No</button><button class='btn btn-success' data-bind='click : yes, html : yes_text'>Yes</button></div> </div> </div> </div>";
    $modal = $('#overlay-confirm');
    if ($modal.length === 0) {
      $modal = $(tmp);
      $modal.appendTo('body');
    } else {
      $modal.koClean();
      $modal.removeClass('animated shake');
    }
    $modal.koBind(vm);
    return $modal.modal({
      backdrop: 'static',
      attentionAnimation: 'shake'
    });
  };

  Overlay.alert = function(msg, opts) {
    var $modal, tmp, vm;
    opts || (opts = {});
    opts.title || (opts.title = "Alert!");
    vm = {
      message: msg,
      title: opts.title,
      ok: function() {
        $('#overlay-alert').modal('hide');
        if (opts.ok != null) {
          return opts.ok();
        }
      }
    };
    tmp = "<div id='overlay-alert' class='modal fade'> <div class='modal-dialog'> <div class='modal-content'> <div class='modal-header'><h4 class='modal-title' data-bind='text : title'></h4></div> <div class='modal-body' style='font-size: 20px;' data-bind='text : message'></div> <div class='modal-footer'><button class='btn btn-primary' data-bind='click : ok'>OK</button></div> </div> </div> </div>";
    $modal = $('#overlay-alert');
    if ($modal.length === 0) {
      $modal = $(tmp);
      $modal.appendTo('body');
    } else {
      $modal.koClean();
    }
    $modal.koBind(vm);
    return $modal.modal({
      backdrop: 'static',
      attentionAnimation: 'shake'
    });
  };

  Overlay.remove = function(id) {
    Overlay.removeModal(id);
    return Overlay.removePopover(id);
  };

  Overlay.removeModal = function(id) {
    return $('#overlay-' + id).trigger('hide.overlay.modal');
  };

  Overlay.removePopover = function(id) {
    var $po;
    $po = $("#popover-" + id);
    return $po.trigger('hide.overlay.popover');
  };

  Overlay.removePopovers = function() {
    return $('.popover').each(function() {
      return $(this).trigger('hide.overlay.popover');
    });
  };

  Overlay.repositionPopover = function(id) {
    return Overlay.utils.positionPopover($("#popover-" + id));
  };

  Overlay.isVisible = function(id) {
    return $('#overlay-' + id).length > 0;
  };

  Overlay.show_loading = function() {
    var $overlay, tpl;
    $overlay = $("#overlay-loading-screen");
    $overlay.remove();
    tpl = "<div id='overlay-loading-screen' class='overlay-loading-screen'><div class='progress progress-striped active'><div class='progress-bar' style='width: 100%'></div></div></div>";
    $overlay = $(tpl);
    return $overlay.appendTo("body").fadeIn();
  };

  Overlay.hide_loading = function() {
    var $overlay;
    $overlay = $("#overlay-loading-screen");
    return $overlay.fadeOut({
      complete: function() {
        return $overlay.remove();
      }
    });
  };

  Overlay.popover = function(el, opts) {
    var $backdrop, $po, container, id, tmp, vm;
    vm = opts.view;
    tmp = opts.template;
    id = vm.name;
    opts.placement || (opts.placement = 'right');
    opts.title || (opts.title = 'Options');
    opts.width || (opts.width = 'auto');
    opts.height || (opts.height = 'auto');
    opts.container || (opts.container = 'body');
    opts.top || (opts.top = -40);
    opts.left || (opts.left = -40);
    opts.anchor = el;
    $po = $("<div id='popover-" + id + "' class='popover fade'> <div class='arrow'></div> <div class='popover-inner'> <button class='close' data-bind='click : hidePopover'>&times;</button> <div class='" + tmp + "' data-bind=\"updateContext : {'$view': $data}, template : '" + tmp + "'\"></div> </div> </div>");
    $backdrop = $("<div class='popover-backdrop'></div>");
    container = opts.container === 'parent' ? $(el).parent() : document.body;
    setTimeout(function() {
      var zidx;
      zidx = Overlay.utils.availableZIndex();
      $po.remove().css({
        top: 0,
        left: 0,
        display: 'block',
        width: opts.width,
        height: opts.height,
        'z-index': zidx
      }).prependTo(container);
      if (opts.backdrop) {
        $backdrop.css({
          'z-index': zidx - 1
        });
        $backdrop.click(function() {
          return $po.trigger('hide.overlay.popover');
        });
        $backdrop.prependTo(document.body);
        opts.$backdrop = $backdrop;
      }
      if (opts.style != null) {
        $po.css(opts.style);
      }
      if (opts.binding != null) {
        $po.attr('data-bind', opts.binding);
      }
      $po.koBind(vm);
      vm.overlay_popover_element = $po[0];
      vm.show();
      $po.click(function(ev) {
        return ev.stopPropagation();
      });
      $po.on('hide.overlay.popover', function() {
        vm.hide();
        vm.overlay_popover_element = null;
        $po.koClean().remove();
        return $backdrop.remove();
      });
      $po.on('reposition.overlay.popover', function() {
        return Overlay.utils.positionPopover($po);
      });
      $po.data('overlay.popover', opts);
      return Overlay.utils.positionPopover($po);
    }, 100);
    return $po[0];
  };

  Overlay.utils = {
    getElementPosition: function(el) {
      var ret;
      ret = $(el).offset();
      ret.width = el.offsetWidth;
      ret.height = el.offsetHeight;
      return ret;
    },
    availableZIndex: function() {
      var idx;
      idx = $('.modal.in, .popover').length;
      return 1040 + (idx * 10);
    },
    positionPopover: function($po) {
      var $arrow, an_h, an_l, an_t, an_w, anchor, anchor_pos, ao_t, left, opts, pl, placement, po_h, po_w, top, win_h, win_w, _i, _len, _ref;
      if ($po.length === 0) {
        return;
      }
      $arrow = $po.find('.arrow');
      opts = $po.data('overlay.popover');
      anchor = opts.anchor;
      anchor_pos = Overlay.utils.getElementPosition(anchor);
      an_t = anchor_pos.top;
      an_l = anchor_pos.left;
      an_w = anchor_pos.width;
      an_h = anchor_pos.height;
      po_w = $po[0].offsetWidth;
      po_h = $po[0].offsetHeight;
      win_w = $(window).width();
      win_h = $(window).height();
      top = 0;
      left = 0;
      placement = null;
      _ref = opts.placement.split(' ');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pl = _ref[_i];
        placement = pl;
        switch (pl) {
          case 'bottom':
            top = an_t + an_h;
            left = an_l + an_w / 2 - po_w / 2;
            break;
          case 'top':
            top = an_t - po_h;
            left = an_l + an_w / 2 - po_w / 2;
            break;
          case 'left':
            left = an_l - po_w;
            if (opts.top === 'center') {
              top = an_t + an_h / 2 - po_h / 2;
            } else {
              top = an_t + opts.top;
            }
            break;
          case 'right':
            left = an_l + an_w;
            if (opts.top === 'center') {
              top = an_t + an_h / 2 - po_h / 2;
            } else {
              top = an_t + opts.top;
            }
        }
        if (pl === 'right' && (left + po_w) > win_w) {
          continue;
        }
        if (pl === 'left' && (left < 0)) {
          continue;
        } else {
          break;
        }
      }
      if (top < 0) {
        top = 0;
      } else if (top + po_h > win_h) {
        top = win_h - po_h;
      }
      if (left < 0) {
        left = 0;
      }
      $po.offset({
        top: top,
        left: left
      }).addClass(placement).addClass('in');
      ao_t = top - an_t;
      if (opts.top !== 'center') {
        return $arrow.css({
          top: Math.abs(ao_t) + an_h / 2
        });
      }
    }
  };

}).call(this);
(function() {
  var Modal;

  Modal = jQuery.fn.modal.Constructor;

  Modal.prototype.basic_show = Modal.prototype.show;

  Modal.prototype.show = function(_relatedTarget) {
    var anim, idx, self;
    self = this;
    this.basic_show(_relatedTarget);
    idx = $('.modal.in, .popover').length;
    idx = Overlay.utils.availableZIndex();
    if (this.$backdrop != null) {
      if (this.options.className != null) {
        this.$backdrop.addClass(this.options.className);
      }
      this.$backdrop.css('z-index', idx - 1);
    }
    this.$element.css('z-index', idx);
    if (this.options.attentionAnimation != null) {
      anim = this.options.attentionAnimation;
      return this.$element.on('click.dismiss.modal', function(ev) {
        if (ev.target !== ev.currentTarget) {
          return;
        }
        console.log('handling click');
        self.$element.removeClass("animated " + anim);
        return setTimeout(function() {
          return self.$element.addClass("animated " + anim);
        }, 10);
      });
    }
  };

}).call(this);
(function() {
  View.prototype.showAsModal = function(tmp, opts) {
    opts || (opts = {});
    opts.view = this;
    opts.template = tmp;
    return Overlay.modal(opts);
  };

  View.prototype.showAsOverlay = View.prototype.showAsModal;

  View.prototype.showAsPopover = function(el, tmp, opts) {
    opts || (opts = {});
    opts.view = this;
    opts.template = tmp;
    return Overlay.popover(el, opts);
  };

  View.prototype.repositionPopover = function() {
    return $(this.overlay_popover_element).trigger('reposition.overlay.popover');
  };

  View.prototype.hideOverlay = function() {
    this.hideModal();
    return this.hidePopover();
  };

  View.prototype.hidePopover = function() {
    if (this.overlay_popover_element != null) {
      return $(this.overlay_popover_element).trigger('hide.overlay.popover');
    }
  };

  View.prototype.hideModal = function() {
    if (this.overlay_modal_element != null) {
      return $(this.overlay_modal_element).trigger('hide.overlay.modal');
    }
  };

  ko.bindingHandlers.popover = {
    init: function(element, valueAccessor, bindingsAccessor, viewModel) {
      var opts;
      opts = valueAccessor();
      opts.view || (opts.view = viewModel);
      return $(element).click(function() {
        return Overlay.popover(element, opts);
      });
    }
  };

  ko.bindingHandlers.tip = {
    init: function(element, valueAccessor, bindingsAccessor, viewModel, bindingContext) {
      var $tip_el, content, opts, tip;
      opts = ko.unwrap(valueAccessor());
      content = opts.template_id != null ? "<div data-bind=\"template : '" + opts.template_id + "'\"></div>" : opts.content;
      opts.placement || (opts.placement = 'bottom');
      opts.html = opts.html || (opts.template_id != null) || false;
      opts.title || (opts.title = content);
      opts.container = 'body';
      $(element).tooltip(opts);
      tip = $(element).data('bs.tooltip');
      $tip_el = tip.tip();
      tip.setContent();
      tip.setContent = function(content) {
        if (content == null) {
          return;
        }
        tip.options.title = content;
        if (opts.template_id != null) {

        } else {
          return $tip_el.find('.tooltip-inner').text(content);
        }
      };
      $tip_el.koBind(viewModel);
      return ko.utils.domNodeDisposal.addDisposeCallback(element, function() {
        $tip_el.koClean();
        return tip.destroy();
      });
    },
    update: function(element, valueAccessor, bindingsAccessor, viewModel, bindingContext) {
      var opts, tip;
      opts = ko.unwrap(valueAccessor());
      tip = $(element).data('bs.tooltip');
      return tip.setContent(opts.content);
    }
  };

  ko.bindingHandlers.loadingOverlay = {
    update: function(element, valueAccessor) {
      var is_loading;
      is_loading = ko.utils.unwrapObservable(valueAccessor());
      if (is_loading) {
        if ($(element).children('.overlay-loading-inline').length === 0) {
          return $(element).prepend("<div class='overlay-loading-inline'>" + (Overlay.templates.loading_overlay()) + "</div>");
        }
      } else {
        return $(element).children('.overlay-loading-inline').fadeOut('fast', (function() {
          return $(this).remove();
        }));
      }
    }
  };

}).call(this);



