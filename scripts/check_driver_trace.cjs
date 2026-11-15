#!/usr/bin/env node
'use strict';
// State-machine unit test with a minimal DOM stand-in, not a browser renderer.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
class Element {
  constructor(tag) {
    this.tag=tag; this.children=[]; this.dataset={}; this.attributes={};
    this.listeners={}; this._text=''; this.disabled=false; this.hidden=false;
  }
  setAttribute(key,value) { this.attributes[key]=String(value); }
  getAttribute(key) { return this.attributes[key]; }
  set textContent(text) { this._text=String(text); this.children=[]; }
  get textContent() { return this._text+this.children.map(child=>child.textContent).join(' '); }
  append(...nodes) { this.children.push(...nodes); }
  matches(selector) {
    const match=/^\[([^\]]+)\]$/.exec(selector);
    return !!match && (Object.hasOwn(this.attributes,match[1]) ||
      (match[1].startsWith('data-')&&Object.hasOwn(this.dataset,match[1].slice(5))));
  }
  querySelectorAll(selector) { return this.children.flatMap(child=>[...(child.matches(selector)?[child]:[]),...child.querySelectorAll(selector)]); }
  querySelector(selector) { return this.querySelectorAll(selector)[0]; }
  addEventListener(name,callback) { (this.listeners[name]??=[]).push(callback); }
  fire(name) { for(const callback of this.listeners[name]??[])callback({target:this}); }
  focus() { this.focused=true; }
}
const root=new Element('section'); root.setAttribute('data-driver-trace','');
function add(tag,name,parent=root) { const node=new Element(tag); node.setAttribute(`data-${name}`,''); parent.append(node); return node; }
const call=add('select','call'); call.value='text';
const showOption=add('option','show-option',call);
const extras=[add('option','extra-option',call),add('option','extra-option',call)];
for(const object of ['display','bus']) {
  const node=add('div','object'); node.dataset.object=object;
  if(object==='display')for(const owner of ['i2c','ssd','frame']) { const item=add('li','owner',node); item.dataset.owner=owner; }
}
const questions=add('div','questions'); add('p','progress'); add('p','guide');
const prediction=add('select','prediction');
const advance=add('button','advance'); const reveal=add('button','reveal'); const reset=add('button','reset');
const feedback=add('p','feedback'); const answer=add('div','answer');
for(const name of ['title','receiver','code','reason'])add('p',name,answer);
const source=fs.readFileSync(path.join(__dirname,'../layouts/shortcodes/driver-call-trace.html'),'utf8');
assert.ok(source.indexOf('class="driver-trace__controls"')<source.indexOf('class="driver-trace__answer"'),'Controls must precede expanding explanations.');
new vm.Script(source.match(/<script>([\s\S]*?)<\/script>/)[1],{filename:'driver-call-trace inline script'})
  .runInNewContext({document:{currentScript:{previousElementSibling:root},createElement:tag=>new Element(tag)}});
function current() { const visible=questions.children.filter(node=>node.dataset.active==='true'); assert.equal(visible.length,1); return visible[0]; }
function checkQuestion(route,index) {
  const expected=`driver-question-${route}-${index}`;
  assert.equal(current().id,expected);
  assert.equal(prediction.getAttribute('aria-describedby'),expected);
  for(const node of questions.children) {
    assert.equal(node.inert,node.id!==expected);
    assert.equal(node.getAttribute('aria-hidden'),String(node.id!==expected));
  }
}
function choose(value) { prediction.value=value; advance.fire('click'); }
function checkAnswer(owner,receiver) {
  assert.equal(answer.hidden,false); assert.equal(prediction.disabled,true); assert.equal(reveal.disabled,true);
  const definitions=root.querySelectorAll('[data-owner]').filter(node=>node.dataset.active==='true');
  assert.deepEqual(definitions.map(node=>node.dataset.owner),owner?[owner]:[]);
  const receivers=root.querySelectorAll('[data-object]').filter(node=>node.dataset.active==='true');
  assert.deepEqual(receivers.map(node=>node.dataset.object),[receiver]);
}
assert.equal(root.dataset.ready,'true'); assert.equal(advance.disabled,false);
checkQuestion('text',0); assert.equal(showOption.disabled,true);
assert.ok(extras.every(node=>node.disabled&&node.hidden));
for(const locked of ['show','construct','invert']) { call.value=locked;call.fire('change'); assert.equal(call.value,'text');checkQuestion('text',0); }
advance.fire('click'); assert.equal(answer.hidden,true); assert.match(feedback.textContent,/Choose an answer/);
choose('ssd'); assert.equal(answer.hidden,true); assert.match(feedback.textContent,/Try again/);checkQuestion('text',0);
choose('frame');checkAnswer('frame','display');advance.fire('click');checkQuestion('text',1);
// A deliberate reveal is available when a student is stuck; it does not claim a correct guess.
prediction.value='image';reveal.fire('click');checkAnswer('frame','display');assert.match(feedback.textContent,/Compare/);
assert.equal(advance.textContent,'Next: show() →');advance.fire('click');checkQuestion('show',0);
assert.equal(showOption.disabled,false);assert.ok(extras.every(node=>node.hidden));
const routes={
 show:[['ssd','ssd','display'],['display','i2c','display'],['bus',null,'bus'],['prepared','ssd','display']],
 construct:[['i2c','i2c','display'],['display','ssd','display'],['i2c','i2c','display'],['one','ssd','display']],
 invert:[['ssd','ssd','display'],['command','ssd','display'],['bus',null,'bus']]
};
let tested=2;
for(const [name,steps] of Object.entries(routes)) {
  if(name!=='show') { call.value=name;call.fire('change'); }
  for(let index=0;index<steps.length;index++) {
    checkQuestion(name,index); assert.equal(answer.hidden,true); assert.equal(prediction.disabled,false);
    assert.equal(root.querySelectorAll('[data-object]').filter(node=>node.dataset.active==='true').length,0);
    if(steps[index][0]==='display') { choose('new');assert.equal(answer.hidden,true);checkQuestion(name,index); }
    choose(steps[index][0]);checkAnswer(steps[index][1],steps[index][2]);tested++;
    if(index<steps.length-1)advance.fire('click');
  }
  advance.fire('click');checkQuestion(name,0);
  if(name==='show') { assert.ok(extras.every(node=>!node.hidden&&!node.disabled));assert.equal(call.focused,true); }
}
call.value='construct';call.fire('change');choose('i2c');advance.fire('click');reset.fire('click');checkQuestion('construct',0);
choose('i2c');call.value='text';call.fire('change');checkQuestion('text',0);assert.equal(answer.hidden,true);
assert.equal(questions.children.length,13);
console.log(`PASS prediction trace: ${tested} steps, wrong/empty answers, explicit reveal, guided unlocks, resets, switching mid-call, and independent class/receiver highlighting. Visual layout not tested.`);
