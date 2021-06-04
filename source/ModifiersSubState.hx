package;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
#if windows
import llua.Lua;
import discord_rpc.DiscordRpc.SecretCallback;
#end
import openfl.Lib;
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

class Modifier extends FlxSprite
{
	public var Name:String;
	public var Multiplier:Float;
	public var Icon:String;
	public var XIndex:Int;
	public var YIndex:Int;
	public var NonSelect:Int;
	public var Select:Int;

	public function new(nonSelect:Int, select:Int, X:Int, Y:Int, name:String, multiplier:Float, ID:String) {
		super();
		XIndex = X;
		YIndex = Y;
		NonSelect = nonSelect;
		Select = select;
		
		antialiasing = true;

		loadGraphic(Paths.image('Modifiers'), true, 128, 128);
		animation.add('anim', [nonSelect, select], 0, false, false);
		x = X*(width) + FlxG.width/4;
		y = Y*(height) + FlxG.height/4;
		scrollFactor.set();
	}
	public override function update(elapsed:Float) {
		super.update(elapsed);
		animation.play('anim');
		if (ModifiersSubState.curSelectedX == XIndex && ModifiersSubState.curSelectedY == YIndex)
			animation.curAnim.curFrame = 1;
		else
			animation.curAnim.curFrame = 0;
	}
}
class ModifiersSubState extends MusicBeatSubstate
{
	public static var curSelectedX:Int = 0;
	public static var curSelectedY:Int = 0;

	var NoFail:Modifier =        new Modifier(0, 1, 0, 0, 'No Fail', 0.5, "NoFail");
	var FastNotes:Modifier =     new Modifier(2, 3, 1, 0, 'Fast Notes', 1.25, "FastNotes");
	var FadeNotes:Modifier =     new Modifier(4, 5, 2, 0, 'Fade Notes', 1.5, "FadeNotes");

	var SlowNotes:Modifier =     new Modifier(6, 7, 0, 1, 'Slow Notes', 0.5, "SlowNotes");
	var PerfectOnly:Modifier =   new Modifier(8, 9, 1, 1, 'Perfect Only', 1.25, "PerfectOnly");
	var Spacebar:Modifier =      new Modifier(10, 11, 2, 1, 'Spacebar', 1.5, "Spacebar");

	var pauseMusic:FlxSound;

	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			Assets.loadSound(path).onComplete(function (_) { });
		}
	}

	public function new(x:Float, y:Float)
	{
		super();
		trace(Paths.music('breakfast', 'shared'));
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast', 'shared'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		add(NoFail);
		add(FastNotes);
		add(FadeNotes);

		add(SlowNotes);
		add(PerfectOnly);
		add(Spacebar);
		FlxTween.tween(bg, {alpha: 0.7}, 0.4, {ease: FlxEase.quartInOut});

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;
		
		if(controls.UP_P)
		{
			CheckVert(-1);
		}
		if(controls.DOWN_P)
		{
			CheckVert(1);
		}
		if(controls.LEFT_P)
		{
			CheckHorz(-1);
		}
		if(controls.RIGHT_P)
		{
			CheckHorz(1);
		}
		super.update(elapsed);
	}

	public function CheckVert(Change:Int) 
	{
		curSelectedY += Change;
		if(curSelectedY < 0)
		{
			curSelectedY = 1;
		}
		if(curSelectedY > 1)
		{
			curSelectedY = 0;
		}
		trace(curSelectedY);
	}

	public function CheckHorz(Change:Int) 
	{
		curSelectedX += Change;
		if(curSelectedX > 2)
		{
			curSelectedX = 0;
		}
		if(curSelectedX < 0)
		{
			curSelectedX = 2;
		}
		trace(curSelectedX);
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}
}