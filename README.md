# Overlay.js

A Javascript library for rendering modals, popovers, etc.

Types of Overlays:
- Modal - Element bound to new View. Displayed using View method.
- Popover - Element bound to new View. Anchored to another element. Displayed using View method.
- Tooltip - Element bound to existing View. Anchored to another element. Displayed using ko binding.
- Dropdown - Element bound to existing View. Anchored to another element. Displayed using ko binding.

## Dependencies

* Twitter Bootstrap > v3.0.0

## Upcoming Changes

* Add all functionality for modal and popover to View prototype methods
* Use View class for additional modals
* For functions on all modals/popovers, find class in document and get data for element, then call hideOverlay
