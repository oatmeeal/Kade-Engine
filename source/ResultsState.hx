package;

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

class ResultsState extends MusicBeatState
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Try Again', 'Exit to menu'];

	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	public function songTitleTweenDone(tween:FlxTween)
	{
		trace("songTitleTweenDone");
		var timer = new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			var songScore:Alphabet = new Alphabet(0, (70 * 1) + 65, "Score ", true, false);
			songScore.x = FlxG.width/4;
			songScore.isMenuItem = false;
			add(songScore);
			
			var seperatedScore:Array<Int> = [];
	
			var comboSplit:Array<String> = (PlayState.songScore + "").split('');

			if (comboSplit.length == 2)
				seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

			for(i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				numScore.screenCenter();
				numScore.x = FlxG.width/4 + 260 + (daLoop*43);
				numScore.y = songScore.y;
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				numScore.updateHitbox();
				add(numScore);
				daLoop++;
			}
		});
	}
	override public function create()
	{
		var icon = new HealthIcon(PlayState.SONG.player2, false);
		icon.x = 25;
		icon.y = 25;
		add(icon);

		icon = new HealthIcon(PlayState.SONG.player1, true);
		icon.x = FlxG.width - icon.width - 25;
		icon.y = 25;
		add(icon);
		var startTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			var songTitle:Alphabet = new Alphabet(0, (70 * 0) + 65, PlayState.SONG.song, true, false);
			songTitle.x = -400;
			songTitle.isMenuItem = false;
			add(songTitle);
			FlxTween.tween(songTitle, {x: FlxG.width/4}, 0.3).onComplete = songTitleTweenDone;
		});
		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 155, menuItems[i], true, false);
			songText.screenCenter(X);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;
	
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
				case "Try Again":
					FlxG.camera.fade(FlxColor.BLACK, 1, false, function()
					{
						LoadingState.loadAndSwitchState(new PlayState());
					});
				case "Exit to menu":
					FlxG.switchState(new FreeplayState());
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
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
			//item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));
			if (item == grpMenuShit.members[curSelected])
			{
					item.alpha = 1;
			// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}