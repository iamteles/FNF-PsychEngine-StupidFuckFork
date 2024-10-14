package objects;

import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

class RatingSprite extends FlxGroup
{
	var daRating:RatingFNF;
	var daNum:NumberFNF;

	var tweens:Array<FlxTween> = [];

	public var numOffset:FlxPoint = new FlxPoint(0,0);
	
	public function new(rating:String, combo:Int, uiPrefix:String = "", uiPostfix:String = "")
	{
		super();
		daRating = new RatingFNF(rating, uiPrefix, uiPostfix);
		add(daRating);
		
		daNum = new NumberFNF(combo, uiPrefix, uiPostfix);
		add(daNum);
		
		setPos();
		
		var single:Bool = !ClientPrefs.data.comboStacking;

		if(!single)
		{
			daRating.acceleration.y = 550;
			daRating.velocity.y 	= -FlxG.random.int(140, 175);
			daRating.velocity.x 	= FlxG.random.int(-10, 10);
		}
		else
		{
			jumpTween(daRating);
		}
		deathTween(daRating, 0.3);
		for(item in daNum)
		{
			if(!single)
			{
				item.acceleration.y = FlxG.random.int(200, 300);
				item.velocity.y 	= -FlxG.random.int(140, 160);
				item.velocity.x 	= FlxG.random.int(-5, 5);
			}
			else
			{
				jumpTween(item);
			}
			deathTween(item, FlxG.random.float(0.2, 0.8));
		}
	}
	
	public function setPos(x:Float = 0, y:Float = 0)
	{
		daRating.x = x - daRating.width / 2;
		daRating.y = y - daRating.height / 2;
		
		var center:Float = daRating.x + daRating.width / 2;
		for(item in daNum)
		{
			item.x = center + ((36 - numOffset.x) * item.ID);
			item.y = daRating.y + daRating.height - numOffset.y;
		}
		
		var lastItem = daNum.members[daNum.members.length - 1];
		var shitLength:Float = lastItem.x + 42 - daNum.members[0].x;
		
		for(item in daNum)
			item.x -= shitLength / 2;
	}

	// makes the thing do a little jump
	public function jumpTween(item:FlxSprite)
	{
		var prevScale = [item.scale.x, item.scale.y];
		item.scale.x *= 1.1;
		item.scale.y *= 1.1;
		tweens.push(FlxTween.tween(item.scale, {x: prevScale[0], y: prevScale[1]}, 0.15, {ease: FlxEase.cubeOut}));
	}
	
	// KILLS the poor thing :[
	public function deathTween(item:FlxSprite, delayTime:Float = 0)
	{
		var daTween = FlxTween.tween(item, {alpha: 0}, Conductor.crochet / 1000, {
			startDelay: delayTime,
			onComplete: function(twn:FlxTween)
			{
				item.destroy();
			}
		});
		tweens.push(daTween);
	}

	override public function kill()
	{
		for(tween in tweens)
			if(tween != null)
				tween.cancel();

		for(item in members)
			if(item != null)
				item.kill();

		super.kill();
	}
}
/*
*	in case you want to spawn them individually for some reason
*/
class RatingFNF extends FlxSprite
{
	public function new(rating:String, uiPrefix:String = "", uiPostfix:String = "")
	{
		super();
		loadGraphic(Paths.image(uiPrefix + rating + uiPostfix));
		
		antialiasing = ClientPrefs.data.antialiasing;

		scale.set(0.7,0.7);
		scale.x *= 0.7;
		scale.y *= 0.7;
		updateHitbox();
	}
}
class NumberFNF extends FlxSpriteGroup
{
	public function new(number:Int, uiPrefix:String = "", uiPostfix:String = "")
	{
		super();
		var numArray:Array<String> = Std.string(number).split("");
		var count:Int = 0;

		for(i in numArray)
		{
			var num = new FlxSprite();
			num.loadGraphic(Paths.image(uiPrefix + 'num' + Std.parseInt(i) + uiPostfix));
			
			num.ID = count;
			count++;

			num.antialiasing = ClientPrefs.data.antialiasing;
			num.scale.set(0.5,0.5);
			num.scale.x *= 0.7;
			num.scale.y *= 0.7;
			num.updateHitbox();

			add(num);
		}
	}
}