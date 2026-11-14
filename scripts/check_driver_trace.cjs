#!/usr/bin/env node
'use strict';
// State-machine unit test with a minimal DOM stand-in. This is not a browser
// renderer and makes no assertions about CSS layout or visual appearance.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

class Element {
  constructor(tag) {
    this.tag = tag;
    this.children = [];
    this.dataset = {};
    this.attributes = {};
    this.listeners = {};
    this._text = '';
    this.disabled = false;
  }
  setAttribute(key, value) { this.attributes[key] = String(value); }
  getAttribute(key) { return this.attributes[key]; }
  set textContent(text) { this._text = String(text); this.children = []; }
  get textContent() { return this._text + this.children.map(child => child.textContent).join(' '); }
  append(...nodes) { this.children.push(...nodes); }
  matches(selector) {
    const match = /^\[([^\]]+)\]$/.exec(selector);
    return !!match && (Object.hasOwn(this.attributes, match[1]) ||
      (match[1].startsWith('data-') && Object.hasOwn(this.dataset, match[1].slice(5))));
  }
  querySelectorAll(selector) {
    return this.children.flatMap(child => [...(child.matches(selector) ? [child] : []), ...child.querySelectorAll(selector)]);
  }
  querySelector(selector) { return this.querySelectorAll(selector)[0]; }
  addEventListener(name, callback) { (this.listeners[name] ??= []).push(callback); }
  fire(name) { for (const callback of this.listeners[name] ?? []) callback({target:this}); }
}
const root = new Element('section');
root.setAttribute('data-driver-trace', '');
function add(tag, name) { const node = new Element(tag); node.setAttribute(`data-${name}`, ''); root.append(node); return node; }
const stage = add('div', 'stage');
const select = add('select', 'call'); select.value = 'show';
const advance = add('button', 'advance');
const reset = add('button', 'reset');
const live = add('p', 'live');
for (const owner of ['i2c','ssd','frame','bus']) { const node = add('li','owner'); node.dataset.owner = owner; }
const source = fs.readFileSync(path.join(__dirname, '../layouts/shortcodes/driver-call-trace.html'), 'utf8');
const script = source.match(/<script>([\s\S]*?)<\/script>/)[1];
new vm.Script(script, {filename:'driver-call-trace inline script'}).runInNewContext({document:{currentScript:{previousElementSibling:root}, createElement:tag=>new Element(tag)}});
assert.equal(root.dataset.ready,'true');
assert.equal(advance.disabled,false);
const active = () => stage.children.filter(card=>card.dataset.active === 'true');
function checkActive(id) {
  assert.equal(active().length,1);
  assert.equal(active()[0].id,id);
  for (const card of stage.children) {
    const visible = card.id === id;
    assert.equal(card.inert,!visible);
    assert.equal(card.getAttribute('aria-hidden'),String(!visible));
  }
  assert.equal(advance.getAttribute('aria-describedby'),id);
}
const expectations = {
  text:['i2c','ssd','frame'],
  show:['i2c','ssd','i2c','bus','i2c','bus'],
  invert:['i2c','ssd','i2c','bus'],
  construct:['i2c','ssd','frame','ssd','bus']
};
let tested = 0;
for (const [route, owners] of Object.entries(expectations)) {
  select.value = route; select.fire('change');
  checkActive(`driver-trace-${route}-0`);
  assert.equal(reset.disabled,true);
  assert.equal(advance.textContent,'Reveal first step');
  for (let step=0;step<owners.length;step++) {
    advance.fire('click');
    checkActive(`driver-trace-${route}-${step+1}`);
    assert.equal(reset.disabled,false);
    const lit=root.querySelectorAll('[data-owner]').filter(owner=>owner.dataset.active==='true');
    assert.equal(lit.length,1);
    assert.equal(lit[0].dataset.owner,owners[step]);
    assert.ok(live.textContent.length>20);
    tested++;
  }
  assert.equal(advance.textContent,'Trace this call again');
  advance.fire('click'); checkActive(`driver-trace-${route}-0`);
  advance.fire('click'); reset.fire('click'); checkActive(`driver-trace-${route}-0`);
}
select.value='show'; select.fire('change'); advance.fire('click'); advance.fire('click');
select.value='text'; select.fire('change'); checkActive('driver-trace-text-0');
assert.equal(root.querySelectorAll('[data-owner]').filter(owner=>owner.dataset.active==='true').length,0);
console.log(`PASS trace unit tests: ${tested} steps across four routes, independent resets, switching mid-call, active-card isolation, and accessible state. Visual layout not tested.`);
