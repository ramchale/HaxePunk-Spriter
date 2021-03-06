package com.haxepunk.spriter;
import openfl.geom.Point;

class SpriteTimelineKey extends SpatialTimelineKey
{
	public function new (parent:Scml, fast:haxe.xml.Fast)
	{
		super(parent, fast);
		
		_parent = parent;
		fast = fast.node.object;
		
		folder = fast.has.folder ? Std.parseInt(fast.att.folder) : 0;
		file = fast.has.file ? Std.parseInt(fast.att.file) : 0;
		useDefaultPivot = (!fast.has.pivot_x && !fast.has.pivot_y);
		pivot_x = fast.has.pivot_x ? Std.parseFloat(fast.att.pivot_x) : 0;
		pivot_y = fast.has.pivot_y ? Std.parseFloat(fast.att.pivot_y) : 1;
	}
	
	public function paint (parentPoint:Point)
	{
		var paintPivotX : Float;
		var paintPivotY : Float;
		
		var _file = _parent.activeCharacterMap[folder].files[file];
		
		if (useDefaultPivot)
		{
			paintPivotX = _file.pivotX;
			paintPivotY = _file.pivotY;
		}
		else
		{
			paintPivotX = pivot_x;
			paintPivotY = pivot_y;
		}
		  
		// paint image represented by
		// ScmlObject.activeCharacterMap[folder].files[file],fileReference 
		// at x,y,angle (counter-clockwise), offset by paintPivotX,paintPivotY
		var image = _file.image;
		image.angle = info.angle;
		image.smooth = _parent.smooth;
		image.alpha = info.alpha;
		image.scaleX = info.scaleX;
		image.scaleY = info.scaleY;
		
		var s = Math.sin(info.angle*HXP.RAD);
		var c = Math.cos(info.angle*HXP.RAD);
		var imagex = -(paintPivotX + 0.0) * image.width * info.scaleX;
		var imagey = (paintPivotY - 1.0) * image.height * info.scaleY;		
		var point = new flash.geom.Point((imagex * c) - (imagey * s) + info.x, (imagex * s) + (imagey * c) - info.y);
		
		point.x += parentPoint.x;
		point.y += parentPoint.y;
		
		#if (flash || js)
		image.render(HXP.buffer, point, HXP.camera);
		#else
		image.renderAtlas(0, point, HXP.camera);
		#end
	}
	
	public override function linear (keyB:TimelineKey, t:Float) : TimelineKey
	{
		if (!Std.is(keyB, SpriteTimelineKey))
			throw "Error should be a SpriteTimelineKey";
			
		var keyB_stk = cast(keyB, SpriteTimelineKey);
		
		var returnKey : SpriteTimelineKey = this;
		returnKey.info = SpatialInfo.linear(info, keyB_stk.info, info.spin, t);
		
		if (!useDefaultPivot)
		{
			returnKey.pivot_x = Utils.linear(pivot_x, keyB_stk.pivot_x, t);
			returnKey.pivot_y = Utils.linear(pivot_y, keyB_stk.pivot_y, t);
		}
		
		return returnKey;
	}
	
	public var folder : Int; // index of the folder within the ScmlObject
	public var file : Int;  
	public var useDefaultPivot : Bool; // true if missing pivot_x and pivot_y in object tag
	public var pivot_x : Float = 0;
	public var pivot_y : Float = 1;
	
	private var _parent : Scml;
}
