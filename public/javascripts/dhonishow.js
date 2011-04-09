// -----------------------------------------------------------------------------------
//
//	Dhonishow v0.6
//	by Stanislav Müller
//	05/20/07
//
//	Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
//
// -----------------------------------------------------------------------------------
//document.write("<style type=\"text/css\" media=\"screen\">.dhonishow {display: none;}</style>");  // to avoid imageload flash

//SpaceFlyer: When you want to use this, make sure that you will adapt dhonishow.css for your images size

var Dhonishow = Class.create();
Dhonishow.prototype = {
	initialize: function() {
		this.parentDiv = arguments[0];

		// customize for default ++++++++++//
		
		this.options = {
			effect : 'appear',   // choose between 'blind', 'slide', 'appear', 'horizontal'
			parallel : true,
			duration : 0.6,
			navigationTop : false,
			hide: {
				'paging': false,
				'alt': false,
				'navigation': false
			},
			target :  "self",
			pagingTemplate: new Template("#{current} of #{allpages}")
		};
		
		// customize for default ----------//

		this.setOptions();
		this.setDependences();
		
		return this;
	},
	
	setOptions: function(){
		
		var options = this.parentDiv.className.match(/(\w+)_(\w+)/g) || [];
		
		options.each(function(option){
			var option = /(\w+)_(\w+)/.exec(option);
			var value = option[2];
			(/dot/).test(value) ?	value = new Number(value.replace(/dot/, ".")) : value;
			option[1] == "hide" ? this.options.hide[value] = true : this.options[option[1]] = value;
		}.bind(this));
				
		this.options.queue = {
			position: 'end', 
			scope: this.parentDiv.id
		};
				
		this.elements = {};
	},
	
	setDependences: function(){
		this.dhonishowCurrentElement = 0;
		
		this.buildDom();
		
		this.updateNavigation();
		this.parentDiv.style.display = 'block';
		this.giveParent(this.dhonishowElements[0]).show();
		this.addObservers();
		this.updateNavigation();
		if(this.options.autoplay) this.handleAutoplay();
	},
	
	buildDom: function(){
						
		this.buildUl = function(){
			var ul = document.createElement('ul');
			new Element.addClassName(ul, "dhonishow-image");
			this.dhonishowElements = [];
			$A(this.parentDiv.childNodes).each(function(el){
				if(el.nodeType != 3){
					var li = document.createElement('li');
					li.style.display="none";
					if(el.getAttribute('rel')){
						var a = document.createElement('a');
						a.href = el.getAttribute('rel'); 	el.removeAttribute("rel");
						a.target = "_"+this.options.target;
						a.appendChild(el);
					}else{
						var a = el;
					}
					li.appendChild(a);
					ul.appendChild(li);
					
					this.dhonishowElements.push(el);
				}
			}.bind(this));
			return ul;
		};

		this.buildNavigation = function(){
			var navi = document.createElement('div');
			new Element.addClassName(navi, 'dhonishow-navi');
		
			var alt = document.createElement('p');
			new Element.addClassName(alt, "dhonishow-picture-alt");
			this.elements.alt = alt;
			
//			navi.appendChild(alt); // SpaceFlyer: Do not show filename
					
			var next_button = document.createElement('a');
			new Element.addClassName(next_button, 'dhonishow-next-picture');
			next_button.setAttribute('title', 'Next');
//			navi.appendChild(next_button); // SpaceFlyer: We don't need this
			next_button.update("Next");
			this.elements.next_button = next_button;
		
		
			var paging = document.createElement('p');
			new Element.addClassName(paging, 'paging');
			navi.appendChild(paging);
			this.elements.paging = paging;
		
			var previous_button = document.createElement('a');
			new Element.addClassName(previous_button, 'dhonishow-previous-picture');
			previous_button.setAttribute('title', 'Previous');
//			navi.appendChild(previous_button); // SpaceFlyer: We don't need this
			previous_button.update("Back");
			this.elements.previous_button = previous_button;
			
			return navi;
		}.bind(this);
		
		this.parentDiv.appendChild(this.buildUl());
		
		if(!this.options.hide.navigation){
			if(this.navigationTop){
				this.parentDiv.insertBefore(this.parentDiv.firstChild, this.buildNavigation());
			}else{
				this.parentDiv.appendChild(this.buildNavigation());
			}
		}
		
/*	Generated HTML Code

			<div id="dhonishow">
				<ul id="dhonishow-image">
					<li><img src="#" /></li>
					...
				</ul>
				<div id="dhonishow-navi">
					<p id="dhonishow-picture-alt"></p>
					<a id="dhonishow-next-picture" title="Next">Next</a>
					<p id="paging"></p>
					<a id="dhonishow-previous-picture" title="previous">Previous</a>
				</div>
			</div>
*/
	},

	addObservers: function(){
		if(!this.options.hide.navigation){
			this.elements.next_button.onclick = function(e){
				this.handleChangeImage(this.dhonishowCurrentElement++);
			}.bindAsEventListener(this);
		
			this.elements.previous_button.onclick = function(e){
				this.handleChangeImage(this.dhonishowCurrentElement--);
			}.bindAsEventListener(this);
		}
	},
	
	removeObservers: function(){
		if(!this.options.hide.navigation){
			this.elements.next_button.onclick = function(){};
			this.elements.previous_button.onclick = function(){};
		}
	},
		
	handleChangeImage: function(dhonishowNextElement){
		this.changeImage(dhonishowNextElement, this.dhonishowCurrentElement);
		this.updateNavigation();
	},
	
	handleAutoplay: function(){
		new PeriodicalExecuter(function(pe){
			if(this.effectStarted == false || typeof(this.effectStarted) == "undefined"){
				this.periodicalExecuterWay = this.periodicalExecuterWay || 'right';
			
				if(this.dhonishowCurrentElement <= this.dhonishowElements.length && this.periodicalExecuterWay == "right"){
					this.dhonishowCurrentElement++;
					if(this.dhonishowCurrentElement == this.dhonishowElements.length){
						this.periodicalExecuterWay = "left";
					}
				}else if(this.periodicalExecuterWay == "left"){
					this.dhonishowCurrentElement--;
					if(this.dhonishowCurrentElement = 1){
						this.periodicalExecuterWay = "right";
					}
				}
			
				if(this.dhonishowCurrentElement == this.dhonishowElements.length){
					this.dhonishowCurrentElement = 0;
					this.changeImage(0, this.dhonishowElements.length-1);
				}else{
					this.changeImage(this.dhonishowCurrentElement, this.dhonishowCurrentElement-1);
				}
				if(!this.options.hide.navigation) this.updateNavigation();
			}
		}.bind(this), this.options.autoplay);
	},
  giveParent: function(elm){
		return elm.up("li");
	},
	giveEffect: function(){
		if(typeof(Effect) != "undefined") {
			return Effect.toggle;
		}else{
			return Element.toggle;
		}
	},
	
	changeImage: function(next, current){
		var effect = this.giveEffect();
		Object.extend(this.options, {
			beforeStart: function(effect){
				this.effectStarted = true;
				this.removeObservers();
			}.bind(this),
			afterFinish: function(effect){
				this.effectStarted = false;
				if(effect.options.to != 0) this.addObservers();
			}.bind(this)
		});
		
		if(this.options.parallel == true && typeof(Effect) != "undefined"){
			new Effect.Parallel([
				new effect(this.giveParent(this.dhonishowElements[next]), this.options.effect, {sync:true}),
				new effect(this.giveParent(this.dhonishowElements[current]), this.options.effect, {sync:true})
			], this.options);
		}else if(typeof(Effect) != "undefined"){
			this.giveParent(this.dhonishowElements[next]).setStyle({zIndex: this.dhonishowElements.length});
			this.giveParent(this.dhonishowElements[current]).setStyle({zIndex: 1});
			
			new effect(this.giveParent(this.dhonishowElements[next]), this.options.effect, this.options);
			new effect(this.giveParent(this.dhonishowElements[current]), this.options.effect, this.options);
		}else{
			new effect(this.giveParent(this.dhonishowElements[next]), this.options.effect, this.options);				// Fallback, prototype's toggle
			new effect(this.giveParent(this.dhonishowElements[current]), this.options.effect, this.options);
		}
	},
	
	updateNavigation: function(){
		if(!this.options.hide.navigation){
			this.elements.previous_button.hide();
			this.elements.next_button.hide();
		
			var updateButton = function(){
				if(this.dhonishowCurrentElement != 0) this.elements.previous_button.show();
				if(this.dhonishowCurrentElement != (this.dhonishowElements.length - 1)) this.elements.next_button.show();
			}.bind(this);
		
			var updatePaging = function(){
				this.elements.paging.update(this.options.pagingTemplate.evaluate({current: this.dhonishowCurrentElement+1, allpages: this.dhonishowElements.length}));
			}.bind(this);
		
			var updateAlt = function(element){
				if(element.getAttribute('alt')){
					var description = element.getAttribute('alt');
				}else if(element.getAttribute('src')){
					var description = element.getAttribute('src').split('/').last();
				}else{
					var description = "";
				}
				this.elements.alt.update(description);
			}.bind(this);
		
			if(this.options.hide.paging == false) updatePaging();
			if(this.options.hide.alt == false) updateAlt(this.dhonishowElements[this.dhonishowCurrentElement]);
		
			updateButton();
		}
	}
};

var SearchDhonishow = Class.create();
SearchDhonishow.prototype = {
	shows: [],
	initialize: function(){
		$$('.dhonishow').each(function(show, number){
			if(show.id == '') show.id = 'dhonishow_'+number;
			this.shows.push(new Dhonishow(show));
		}.bind(this));
	}	
};

if(typeof(Effect) != "undefined"){
	Effect.SlideRight = function(element) {
	  element = $(element).cleanWhitespace();
	  var elementDimensions = element.getDimensions();
	  return new Effect.Scale(element, 100, Object.extend({
	    scaleContent: true, 
	    scaleX: true,
			scaleY: false,
	    scaleFrom: window.opera ? 0 : 1,
	    scaleMode: {originalHeight: elementDimensions.height, originalWidth: elementDimensions.width},
	    restoreAfterFinish: true,
	    afterSetup: function(effect) {
	      effect.element.makePositioned();
	      effect.element.down().makePositioned();
	      effect.element.makeClipping().show();
	    },
	    afterFinishInternal: function(effect) {
	      effect.element.undoClipping().undoPositioned();
	      effect.element.down().undoPositioned();
			}}, arguments[1] || {})
	  );
	};

	Effect.Slideleft = function(element) {
	  element = $(element).cleanWhitespace();
	  return new Effect.Scale(element, window.opera ? 0 : 1,
	   Object.extend({ scaleContent: false, 
	    scaleX: true,
	 		scaleY: false,
	    scaleMode: 'box',
	    scaleFrom: 100,
	    restoreAfterFinish: true,
	    beforeStartInternal: function(effect) {
	      effect.element.makePositioned();
	      effect.element.down().makePositioned();
	      effect.element.makeClipping().show();
	    },
	    afterFinishInternal: function(effect) {
	      effect.element.hide().undoClipping().undoPositioned();
	      effect.element.down().undoPositioned();
	    }}, arguments[1] || {}));
	};

	Effect.toggle = function(element, effect) {
		element = $(element);
	  effect = (effect || 'appear').toLowerCase();
	  var options = Object.extend({
	    queue: { position:'end', scope:(element.id || 'global'), limit: 1 }
	  }, arguments[2] || {});
	  return new Effect[element.visible() ? Effect.PAIRS[effect][1] : Effect.PAIRS[effect][0]](element, options);
	};

	Object.extend(Effect.PAIRS, {'horizontal': ['SlideRight', 'Slideleft']});
}

