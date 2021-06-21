package;

import flixel.FlxSprite;

class Pillar extends FlxSprite
{
	public function new(X:Float, Y:Float) {
		super(X, Y);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		x += 25;
	}
}