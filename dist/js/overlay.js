(function() {
  this.Overlay = (function() {
    function Overlay() {
      this.zindex = 100;
      this.notifyTimer = null;
      $(document).click(function() {
        return Overlay.removePopovers();
      });
    }

    return Overlay;

  })();

  Overlay.instance = new Overlay();

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
    modal_tpl = "<div id='overlay-" + id + "' class='modal fade'><div class='modal-dialog'><div class='modal-content'><button class='close' data-bind='click : hideOverlay'>&times;</button><div class='" + template + "' data-bind=\"template: '" + template + "'\"></div></div></div></div>";
    $modal_el = $(modal_tpl).appendTo('body');
    $modal_dialog = $modal_el.find('.modal-dialog');
    if (opts.width != null) {
      $modal_dialog.css({
        width: opts.width + 'px'
      });
    }
    $modal_dialog.css(css_opts);
    $modal_el.addClass(cls);
    return setTimeout(function() {
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
        if (vm.onHidden != null) {
          vm.onHidden();
        }
        if (opts.hidden) {
          return opts.hidden();
        }
      });
      $modal_el.on('shown.bs.modal', function(ev) {
        if (ev.target.id !== ("overlay-" + id)) {
          return;
        }
        if (vm.onShown != null) {
          vm.onShown(ev.target);
        }
        if (opts.shown != null) {
          return opts.shown;
        }
      });
      return $modal_el.modal(opts);
    }, 100);
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
    type = type || 'info';
    Overlay.clearNotifications();
    $('body').prepend("<div id='overlay-notify' class='overlay-notify-elegant " + type + " p-" + opts.position + "' style='display: none;'><img class='icon' src='" + AssetsLibrary['overlay-notify'] + "'/><div class='title'>" + msg + "</div></div>");
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
    vm = {
      message: msg,
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
      }
    };
    tmp = "<div id='overlay-confirm' class='modal fade'> <div class='modal-dialog'> <div class='modal-content'> <div class='modal-header'><h4 class='modal-title'>Continue?</h4></div> <div class='modal-body' style='font-size: 20px;' data-bind='text : message'></div> <div class='modal-footer'><button class='btn btn-danger' data-bind='click : no'>No</button><button class='btn btn-success' data-bind='click : yes'>Yes</button></div> </div> </div> </div>";
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
    vm = {
      message: msg,
      ok: function() {
        $('#overlay-alert').modal('hide');
        if (opts.ok != null) {
          return opts.ok();
        }
      }
    };
    tmp = "<div id='overlay-alert' class='modal fade'> <div class='modal-dialog'> <div class='modal-content'> <div class='modal-header'><h4 class='modal-title'>Alert!</h4></div> <div class='modal-body' style='font-size: 20px;' data-bind='text : message'></div> <div class='modal-footer'><button class='btn btn-primary' data-bind='click : ok'>OK</button></div> </div> </div> </div>";
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
    $('#overlay-' + id).modal('hide');
    $('#backdrop-' + id).remove();
    if (id === 'confirm') {
      return $('#overlay-' + id).remove();
    }
  };

  Overlay.removePopover = function(id) {
    var $po;
    $po = $("#popover-" + id);
    return $po.trigger('hidden.overlay.popover');
  };

  Overlay.removePopovers = function() {
    return $('.popover').each(function() {
      return $(this).trigger('hidden.overlay.popover');
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
    var $po, id, tmp, vm;
    vm = opts.view;
    tmp = opts.template;
    id = vm.name;
    opts.placement || (opts.placement = 'bottom');
    opts.title || (opts.title = 'Options');
    opts.width || (opts.width = 'auto');
    opts.height || (opts.height = 'auto');
    opts.element = el;
    $po = $("<div id='popover-" + id + "' class='popover fade'> <div class='arrow'></div> <div class='popover-inner'> <button class='close' data-bind='click : hidePopover'>&times;</button> <h3 class='popover-title'>" + opts.title + "</h3> <div class='popover-content' data-bind=\"template : '" + tmp + "'\"></div> </div> </div>");
    return setTimeout(function() {
      var zidx;
      zidx = Overlay.utils.availableZIndex();
      $po.remove().css({
        top: 0,
        left: 0,
        display: 'block',
        width: opts.width,
        height: opts.height,
        'z-index': zidx
      }).prependTo(document.body);
      if (opts.style != null) {
        $po.css(opts.style);
      }
      $po.koBind(vm);
      $po.click(function(ev) {
        return ev.stopPropagation();
      });
      $po.on('hidden.overlay.popover', function() {
        if (typeof vm.onHidden === "function") {
          vm.onHidden();
        }
        return $po.koClean().remove();
      });
      $po.data('popover', opts);
      return Overlay.utils.positionPopover($po);
    }, 100);
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
      var actualHeight, actualWidth, el, opts, pos, tp;
      if ($po.length === 0) {
        return;
      }
      opts = $po.data('popover');
      el = opts.element;
      pos = Overlay.utils.getElementPosition(el);
      actualWidth = $po[0].offsetWidth;
      actualHeight = $po[0].offsetHeight;
      switch (opts.placement) {
        case 'bottom':
          tp = {
            top: pos.top + pos.height,
            left: pos.left + pos.width / 2 - actualWidth / 2
          };
          break;
        case 'top':
          tp = {
            top: pos.top - actualHeight,
            left: pos.left + pos.width / 2 - actualWidth / 2
          };
          break;
        case 'left':
          tp = {
            top: pos.top + pos.height / 2 - actualHeight / 2,
            left: pos.left - actualWidth
          };
          break;
        case 'right':
          tp = {
            top: pos.top + pos.height / 2 - actualHeight / 2,
            left: pos.left + pos.width
          };
      }
      if (tp.top < 0) {
        tp.top = 0;
      }
      if (tp.left < 0) {
        tp.left = 0;
      }
      return $po.css(tp).addClass(opts.placement).addClass('in');
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
  View.prototype.showAsOverlay = function(tmp, opts) {
    opts || (opts = {});
    opts.view = this;
    opts.template = tmp;
    return Overlay.modal(opts);
  };

  View.prototype.showAsPopover = function(el, tmp, opts) {
    opts || (opts = {});
    opts.view = this;
    opts.template = tmp;
    return Overlay.popover(el, opts);
  };

  View.prototype.repositionPopover = function() {
    return Overlay.repositionPopover(this.name);
  };

  View.prototype.hideOverlay = function() {
    return Overlay.remove(this.name);
  };

  View.prototype.hidePopover = function() {
    return Overlay.removePopover(this.name);
  };

  View.prototype.overlayVisible = function() {
    return Overlay.isVisible(this.name);
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

  ko.bindingHandlers.loadingOverlay = {
    update: function(element, valueAccessor) {
      var is_loading;
      is_loading = ko.utils.unwrapObservable(valueAccessor());
      if (is_loading) {
        if ($(element).children('.overlay-loading-inline').length === 0) {
          return $(element).prepend("<div class='overlay-loading-inline'><img src='" + AssetsLibrary['overlay-spinner'] + "'/></div>");
        }
      } else {
        return $(element).children('.overlay-loading-inline').fadeOut('fast', (function() {
          return $(this).remove();
        }));
      }
    }
  };

}).call(this);



