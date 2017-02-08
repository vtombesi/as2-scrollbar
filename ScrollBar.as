import mx.utils.Delegate; 
import flash.filters.BlurFilter; 

class ScrollBar extends MovieClip {
	
	private var percentuale:Number = 0;
	
	private var obj_minY:Number;
	private var obj_maxY:Number; 
	private var obj_endY:Number; 
	private var obj_diffY:Number; 
	private var content_starty:Number;
	
	private var ruler_min_y:Number; 
	private var ruler_max_y:Number; 
	private var dragged_min_y:Number; 
	private var dragged_max_y:Number; 
	private var dragged_start_y:Number; 
	
	private var ruler_clip:MovieClip; 
	private var background_clip:MovieClip;  
	private var dragged_clip:MovieClip;
	private var mask_clip:MovieClip;

	private var wheelFactor:Number; 
	private var scrollFactor:Number;
	private var rulerFactor:Number; 
	private var blurred:Boolean; 
	private var blurFactor:Number; 
	private var pixelhinting:Boolean; 
	private var rulerAdjust:Boolean; 
	private var cached:Boolean; 
	
	private var errors:Array; 
	
	private var bf:BlurFilter;	

	function ScrollBar() {
		// constructor
	}
	
	function setScrollbar(params:Object) {
		for (var m in params) {
			switch (m) {
				case "content": 
					this.dragged_clip = params[m];
					break; 
				case "ruler":
					this.ruler_clip = params[m];
					break; 
				case "background": 
					this.background_clip = params[m];
					break; 
				case "mask": 
					this.mask_clip = params[m];
					break; 
				case "blurred": 
					this.blurred = params[m];
					break; 
				case "pixelhinting": 
					this.pixelhinting = params[m];
					break; 
				case "rulerAdjust": 
					this.rulerAdjust = params[m]; 
					break; 
				case "cached": 
					this.cached = params[m]; 
					break; 					
				case "scrollFactor": 
					this.scrollFactor = params[m]; 
					if (this.scrollFactor < 1) 
						this.scrollFactor = 1; 
					this.rulerFactor = this.scrollFactor; 	
					break; 
				case "rulerFactor": 
					this.rulerFactor = params[m];				
					break; 
				case "blurFactor": 
					this.blurFactor = params[m]; 
					break; 					
			}
			this.reset(); 
		}
		
		errors = new Array(); 
		if (dragged_clip == undefined) {
			errors.push("No dragged clip defined"); 
		}
		if (mask_clip == undefined) {
			errors.push("No mask clip defined"); 
		}
		if (ruler_clip == undefined) {
			errors.push("No scrollbar ruler clip defined"); 
		}
		if (background_clip == undefined) {
			errors.push("No scrollbar background clip defined"); 
		}
		
		if (scrollFactor == undefined) {
			scrollFactor = 10; 
		}
		if (rulerFactor == undefined) {
			rulerFactor = scrollFactor; 
		}
		if (blurred == undefined) {
			blurred = false; 
		}
		if (blurFactor == undefined) {
			blurFactor = 8; 
		}		
		if (cached == undefined) {
			cached = false; 
		}
		if (rulerAdjust == undefined) {
			rulerAdjust = true; 
		}
		if (pixelhinting == undefined) {
			pixelhinting = false; 
		}
	}
	function getPoints() {
		ruler_min_y = 0; 
		ruler_max_y = background_clip._height - ruler_clip._height; 
		
	}
	function start() {
		reset(); 
		
		if (errors.length > 0) {
			logErrors(); 
		} else {
			getPoints();
			
			if (blurred) {
				bf = new BlurFilter(0, 0, 1); 
				this.dragged_clip.filters = new Array(bf); 
			}
			
			this.dragged_clip.cacheAsBitmap = this.cached; 
			
			content_starty = dragged_clip._y; 
			
			var mouseListener:Object = new Object();
			mouseListener.target = this;
			
			mouseListener.onMouseWheel = Delegate.create(this, MouseWheelCheck); 
			Mouse.addListener(mouseListener);
			
			ruler_clip.onRelease = ruler_clip.onReleaseOutside = Delegate.create(this, ReleaseHandle); 
			ruler_clip.onPress = Delegate.create(this, PressHandle); 
			this.onEnterFrame = Delegate.create(this, Render); 
		}
	}
	function MouseWheelCheck(delta) {
		if (dragged_clip.hitTest(_root._xmouse, _root._ymouse, false)) {
			this.scrollData(delta);
		}
	}
	function PressHandle() {
		this.ruler_clip.onEnterFrame = null;
		this.ruler_clip.startDrag(false, 0, ruler_min_y, 0, ruler_max_y); 
	}
	function ReleaseHandle() {
		this.ruler_clip.stopDrag(); 
	}
	function Render() {
		var minY:Number; 
		var maxY:Number; 
		var curY:Number;
		var limit:Number;
		var finalX:Number; 
		var diffy:Number; 
		
		if (rulerAdjust) {
			ruler_clip._height = (mask_clip._height / dragged_clip._height) * background_clip._height;
			getPoints(); 
		}
		
		limit = background_clip._y; 
		if (ruler_clip._y < limit) {
			ruler_clip._y = limit; 
		}
		limit = background_clip._height - ruler_clip._height; 
		if (ruler_clip._y > limit) {
			ruler_clip._y = limit; 
		} 		
		
		checkContentLength();			
		
		percentuale = (100 / ruler_max_y) * ruler_clip._y;
		
		minY = 0;
		maxY = (dragged_clip._height - (mask_clip._height / 2)) * 1;
		
		curY = content_starty; 
		var halfMaskHeight:Number = (mask_clip._height / 2); 
		
		if (ruler_clip._visible == true) {
			finalX = curY - (((maxY - halfMaskHeight) / 100) * percentuale); 
			diffy = finalX - dragged_clip._y;
		} else {
			finalX = content_starty; 
		}
		
		if (dragged_clip._y != finalX) {
			
			var increment = diffy / scrollFactor; 
			
			if (pixelhinting) {
				increment = Math.round(increment); 
			}
			
			dragged_clip._y += increment; 
			
			var bfactor:Number = Math.abs(diffy) / blurFactor; 
			
			bf.blurY = bfactor/2; 
			if (blurred == true) {
				dragged_clip.filters = new Array(bf);
			}			
			
		}
		
		
	}
	function scrollData(delta:Number) {
		var d:Number;
		var fy:Number, cy:Number, pages:Number; 
		if (delta > 1) {
			delta = 1;
		}
		if (delta < -1) {
			delta = -1;
		}
		
		pages = Math.ceil(dragged_clip._height / mask_clip._height); 
		wheelFactor = background_clip._height / (pages); 
		
		d = -(delta * wheelFactor);
		
		if (d > 0) {
			var rulerY:Number = Math.min(ruler_max_y, ruler_clip._y + d);
		}
		if (d < 0) {
			var rulerY:Number = Math.max(ruler_min_y, ruler_clip._y + d);
		}
		
		fy = rulerY; 
		
		ruler_clip._y = rulerY; 
	}
	
	public function checkContentLength() {
		if (dragged_clip._height < mask_clip._height) {
			ruler_clip._visible = false;
			reset();
		} else {
			ruler_clip._visible = true; 
		}
	}
	
	public function reset() {
		dragged_clip._y = content_starty; 
		dragged_clip.filters = null; 
		ruler_clip.y = 0; 			
	}	
	
	private function logErrors() {
		trace("## ERRORS: "); 
		for (var m = 0; m < errors.length; m++) {
			trace("> " + errors[m]); 
		}
	}

}