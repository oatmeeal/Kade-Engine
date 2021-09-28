package;

import flixel.tweens.misc.VarTween;
import flixel.util.FlxTimer;
import openfl.Lib;
#if windows
import llua.Lua;
#end
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ModifiersState extends MusicBeatState
{
	var curSelected:Int = 0;

	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Play', 'No Fail', 'Fast Notes', 'Slow Notes', 'Perfect Only', 'Spacebar WIP'];
	var menuItemsEnabled:Map<String, Dynamic> = ['No Fail' => {multiplier: 0, enabled: false}, 'Fast Notes' => {multiplier: 1.2, enabled: false}, 'Fade Notes' => {multiplier: 1.15, enabled: false}, 'Slow Notes' => {multiplier: 0.75, enabled: false}, 'Perfect Only' => {multiplier: 1.5, enabled: false}, 'Spacebar WIP' => {multiplier: 1, enabled: false}];
	
	var sussyBaka:FlxText;

	var oatr:FlxSprite;
	var tweenin:VarTween;

	function tweenEnd(tween:FlxTween):Void 
	{
		tweenin = FlxTween.tween(oatr, {y: -255}, 1.6, {ease: FlxEase.quadInOut, type: PINGPONG});
	}

	override public function create()
	{
		var timer = new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			FlxG.sound.playMusic(Paths.music('breakfast'));
			oatr = new FlxSprite((FlxG.width/4)+100, -300, Paths.image('oatyThumbsUp'));
			oatr.y = oatr.height;
			add(oatr);
			tweenin = FlxTween.tween(oatr, {y: -270}, 1.6, {ease: FlxEase.expoOut, onComplete: tweenEnd});

			sussyBaka = new FlxText(-10,FlxG.height - 25, 0, "Multiplier: N/A", 25);
			sussyBaka.setFormat(Paths.font("BalooTammudu2-SemiBold.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			sussyBaka.scrollFactor.set();
			add(sussyBaka);

			grpMenuShit = new FlxTypedGroup<Alphabet>();
			add(grpMenuShit);

			for (i in 0...menuItems.length)
			{
				var string = menuItems[i];
				trace(string);
				var songText:Alphabet = new Alphabet(0, (70 * i) + 155, string, true, false);
				songText.screenCenter(X);
				songText.isMenuItem = true;
				songText.targetY = i;
				grpMenuShit.add(songText);
			}

			changeSelection();
		});
		super.create();
	}
	override function update(elapsed:Float)
	{
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
	
		if (upP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(-1);
	   
		}else if (downP)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeSelection(1);
		}
	
		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case 'Play':
					PlayState.modifiers = menuItemsEnabled;
					var tweenout = FlxTween.tween(oatr, {y: -oatr.height}, 1.6, {ease: FlxEase.expoOut});
					var timer = new FlxTimer().start(1.4, function(tmr:FlxTimer)
					{
						oatr.destroy();
						grpMenuShit.destroy();
						FlxG.switchState(new PlayState());
					});
				default:
					FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
					menuItemsEnabled[daSelected].enabled = !menuItemsEnabled[daSelected].enabled;
					changeSelection();

			}
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0):Void
		{
			curSelected += change;
		
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
			if (curSelected >= menuItems.length)
				curSelected = 0;
		
			var bullShit:Int = 0;
		
			for (item in grpMenuShit.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;
	
				item.alpha = 0.6;
				// item.setGraphicSize(Std.int(item.width * 0.8));
				if (item == grpMenuShit.members[curSelected])
				{
					item.alpha = 1;
					if(item.text != 'Play')
					{
						sussyBaka.text = 'Multiplier: ' + menuItemsEnabled[item.text].multiplier + ' - ' + (menuItemsEnabled[item.text].enabled ? 'On' : 'Off');
					}
				// item.setGraphicSize(Std.int(item.width));
				}
			}
		}
}