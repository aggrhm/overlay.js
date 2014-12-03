# Overlay.js

A Javascript library for rendering modals, popovers, etc.

Types of Overlays:
- Modal - Element bound to new View. Displayed using View method.
- Popover - Added as embedded component. Custom positioning in view.
- Tooltip - Element bound to existing View. Anchored to another element. Displayed using ko binding.
- Dropdown - Element bound to existing View. Anchored to another element. Displayed using ko binding.

Other Notes:
- Use View to add element to body, or add inline using view component or basic template (like a dropdown).
- Use events to interact with dynamically added elements.

## Dependencies

* Twitter Bootstrap > v3.0.0

## Upcoming Changes

* View showAsModal and showAsPopover should use custom logic to build template element, add to DOM body, and position as necessary
* Extend Twitter Bootstrap Model and Tooltip classes to better support Knockout 
* Add all functionality for modal and popover to View prototype methods
* Use View class for additional modals
