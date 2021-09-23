package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
// might do this shit later: import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxGradient;
import flixel.math.FlxMath;
// import io.newgrounds.NG;
import lime.utils.Assets;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuBG:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];

	var magenta:FlxSprite;
	var bg:FlxSprite;
	var blueBG:FlxSprite;
	var camFollow:FlxObject;

	var category:Int = 0;
	var isAnim:Bool = false;

	override function create()
	{
		Settings.init();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.15;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		FlxGradient.overlayGradientOnFlxSprite(bg, Std.int(bg.width), Std.int(bg.height), [FlxColor.RED, FlxColor.TRANSPARENT], 0, 0, 1, 90, true);
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.15;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		FlxGradient.overlayGradientOnFlxSprite(magenta, Std.int(magenta.width), Std.int(magenta.height), [FlxColor.RED, FlxColor.TRANSPARENT], 0, 0, 1, 90, true);
		add(magenta);
		// magenta.scrollFactor.set();

		menuBG = new FlxTypedGroup<FlxSprite>();
		add(menuBG);

		for (i in 0...3)
		{
			var fgMenu:FlxSprite = new FlxSprite(-10, FlxG.height + 80).loadGraphic(Paths.image('menuFG'));
			fgMenu.scrollFactor.set(0, 0.20 * i);
			fgMenu.setGraphicSize(Std.int(fgMenu.width * 1.1));
			fgMenu.updateHitbox();
			fgMenu.screenCenter();

			fgMenu.y += 240;
			fgMenu.y -= 40 * i;
			fgMenu.alpha = 1 - (1 - (i / 10));
			menuBG.add(fgMenu);
			fgMenu.antialiasing = true;
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set(0.02, 0.02);
			menuItem.antialiasing = true;
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var coolString:String = Assets.getText("version/version.txt");

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, coolString, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		#if tester
		versionShit += '-TESTER';
		#end
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	var formerWidth:Int;
	var formerHeight:Int;
	var startResize:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.save.data.musicVolume == 100)
		{
			if (FlxG.sound.music.volume < 0.8)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		else
		{
			if (FlxG.sound.music.volume < FlxG.save.data.musicVolume / 100)
				FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (startResize)
		{
			blueBG.setGraphicSize(Math.floor(FlxMath.lerp(blueBG.width, formerWidth, 0.75)), Math.floor(FlxMath.lerp(blueBG.height, formerHeight, 0.75)));
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), FlxG.save.data.soundVolume);
				changeItem(1);
			}

			/*
				#if debug
				if (controls.RIGHT_P)
				{
					var code:Int = 0;
					
					trace('exited game with code of ' + code);
					Sys.exit(code);
				}
				#end */

			if (controls.BACK)
			{
				if (!isAnim)
					FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;

				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
					#else
					FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
					#end
				}
				else
				{
					selectedSomethin = true;
					isAnim = true;
					FlxG.sound.play(Paths.sound('confirmMenu'), FlxG.save.data.soundVolume);

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0, x: FlxG.width * 0.7}, 1, {ease: FlxEase.quadOut});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());
										trace("Freeplay Menu Selected");
									case 'options':
										FlxG.switchState(new SettingsMenu());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(change:Int = 0)
	{
		curSelected += change;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
