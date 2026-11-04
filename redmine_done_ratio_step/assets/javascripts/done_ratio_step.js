// Replaces the core "% Done" dropdown (multiples of 10) with a slider and/or
// number input that follows the step configured in the plugin settings.
// Covers the issue form (new/edit, including AJAX form refresh) and bulk edit.
(function () {
  'use strict';

  var SELECT_SELECTOR = 'select#issue_done_ratio';
  var config = { step: 10, mode: 'slider' };
  // name => last value entered by the user. Restored when Redmine re-renders
  // the form via AJAX, because the core dropdown cannot hold e.g. 37.
  var lastValues = {};

  function readConfig() {
    var meta = document.querySelector('meta[name="redmine-done-ratio-step"]');
    if (!meta) return;
    var step = parseInt(meta.getAttribute('data-step'), 10);
    if (step >= 1 && step <= 100) config.step = step;
    config.mode = meta.getAttribute('data-mode') === 'number' ? 'number' : 'slider';
  }

  function clamp(n) {
    return Math.min(100, Math.max(0, n));
  }

  // Allowed values: multiples of step below 100, plus 100 itself.
  function snap(n) {
    var lower = Math.floor(n / config.step) * config.step;
    var upper = Math.min(lower + config.step, 100);
    return (n - lower < upper - n) ? lower : upper;
  }

  function stepFrom(n, direction) {
    if (direction > 0) return Math.min(100, (Math.floor(n / config.step) + 1) * config.step);
    return Math.max(0, (Math.ceil(n / config.step) - 1) * config.step);
  }

  // Returns '' for blank, null for garbage, otherwise a clamped integer.
  function parse(raw) {
    raw = String(raw == null ? '' : raw).trim();
    if (raw === '') return '';
    var n = parseInt(raw, 10);
    return isNaN(n) ? null : clamp(n);
  }

  function initialValue(select, allowBlank) {
    var value;
    if (Object.prototype.hasOwnProperty.call(lastValues, select.name)) {
      value = parse(lastValues[select.name]);
    } else {
      var holder = select.form && select.form.querySelector('.done-ratio-step-value');
      // Existing values are kept as-is (not snapped) so saving an untouched
      // form never changes them.
      value = parse(holder ? holder.getAttribute('data-value') : select.value);
    }
    if (value === null || (value === '' && !allowBlank)) value = allowBlank ? '' : 0;
    return value;
  }

  function labelText(select) {
    var label = document.querySelector('label[for="' + select.id + '"]');
    return label ? label.textContent.replace(/\s+/g, ' ').trim() : '% Done';
  }

  function enhance(select) {
    var name = select.name;
    var allowBlank = !!select.querySelector('option[value=""]');
    var current = initialValue(select, allowBlank);

    var wrapper = document.createElement('span');
    wrapper.className = 'done-ratio-step done-ratio-step-' + config.mode;

    var number = document.createElement('input');
    number.type = 'text';
    number.inputMode = 'numeric';
    number.autocomplete = 'off';
    number.maxLength = 3;
    number.id = select.id;
    number.name = name;
    number.className = 'done-ratio-step-number';
    number.disabled = select.disabled;
    if (allowBlank) number.placeholder = select.querySelector('option[value=""]').textContent;

    var range = null;
    if (config.mode === 'slider') {
      range = document.createElement('input');
      range.type = 'range';
      range.min = '0';
      range.max = '100';
      // Non-divisor steps (e.g. 3) still need to reach 100; snapping handles it.
      range.step = String(100 % config.step === 0 ? config.step : 1);
      range.className = 'done-ratio-step-range';
      range.disabled = select.disabled;
      range.setAttribute('aria-label', labelText(select));
      wrapper.appendChild(range);
    }

    var unit = document.createElement('span');
    unit.className = 'done-ratio-step-unit';
    unit.textContent = '%';
    wrapper.appendChild(number);
    wrapper.appendChild(unit);

    function setValue(value, byUser, fireChange) {
      current = value;
      number.value = value === '' ? '' : String(value);
      if (range) range.value = String(value === '' ? 0 : value);
      wrapper.classList.toggle('done-ratio-step-blank', value === '');
      if (byUser) lastValues[name] = number.value;
      if (fireChange) number.dispatchEvent(new Event('change', { bubbles: true }));
    }

    function commitTyped() {
      var value = parse(number.value);
      if (value === null || (value === '' && !allowBlank)) value = current;
      else if (value !== '') value = snap(value);
      setValue(value, true, false);
    }

    function onArrowKey(event) {
      var direction = { ArrowUp: 1, ArrowRight: 1, ArrowDown: -1, ArrowLeft: -1 }[event.key];
      // Left/Right move the caret inside the text box; only the slider uses them.
      if (!direction || (event.target === number && /Left|Right/.test(event.key))) return;
      event.preventDefault();
      var base = parse(number.value);
      if (base === null) base = current;
      setValue(base === '' ? 0 : stepFrom(base, direction), true, true);
    }

    number.addEventListener('change', commitTyped);
    number.addEventListener('keydown', onArrowKey);
    if (range) {
      range.addEventListener('input', function () {
        setValue(snap(parseInt(range.value, 10)), true, false);
      });
      range.addEventListener('change', function () {
        number.dispatchEvent(new Event('change', { bubbles: true }));
      });
      range.addEventListener('keydown', onArrowKey);
    }

    // Enter submits the form without always firing "change" first.
    if (select.form && !select.form.hasAttribute('data-done-ratio-step')) {
      select.form.setAttribute('data-done-ratio-step', '1');
      select.form.addEventListener('submit', function (event) {
        var input = event.target.querySelector('.done-ratio-step-number');
        if (input) input.dispatchEvent(new Event('change'));
      }, true);
    }

    setValue(current, false, false);
    select.parentNode.replaceChild(wrapper, select);
  }

  function scan() {
    var selects = document.querySelectorAll(SELECT_SELECTOR);
    for (var i = 0; i < selects.length; i++) enhance(selects[i]);
  }

  function init() {
    readConfig();
    scan();
    // Redmine replaces the issue form / bulk edit form via AJAX
    // (tracker, status, project change). Re-enhance the new dropdown.
    new MutationObserver(scan).observe(document.body, { childList: true, subtree: true });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
