function exitToDesktop() {
	game_end();
}

function returnToMenuSelection() {
	
	oPostProcess.ppfx.ProfileUnload();
	room_goto(rHome);
	
	for (var _i = 0; _i < instance_count - 1; ++_i)
	{
	    var _instance = instance_find(all,_i);
			
			
		if(variable_instance_exists(_instance, "cleanupInstance") && _instance.cleanupInstance == true) {
			instance_destroy(_instance);
		}
	}
	

}

function unpause() {
	global.pause = false;
}

/// @func Menu item options
/// @param {Array<Struct.Platforms>} _platforms List of plateforms. If empty, will be available to all
/// @param {Asset.GMSound} _sound List of plateforms. Sound to play when triggering
/// @param {Real} _selectedOpacity Opacity for selected item
/// @param {Real} _unselectedOpacity Opacity for unselected item
function MenuItemOptions(
	_platforms = [],
	_sound = sndMenuClick,
	_selectedOpacity = 1.0,
	_unselectedOpacity = 0.7,
) constructor {
	platforms = _platforms;
	sound = _sound;
	selectedOpacity = _selectedOpacity;
	unselectedOpacity = _unselectedOpacity;
	halign = undefined;
	valign = undefined;
	offsetX = undefined;
	offsetY = undefined;
	minimalWidth = undefined;	
	doubleWidth = undefined;

}

/// @func Menu item
/// @param {String} _name The text for the option
/// @param {Function} _action The action to execute
/// @param {Struct.MenuItemOptions} _option Options for the item
function MenuItem(
	_name,
	_action = undefined,
	_option = new MenuItemOptions()
) constructor {
	name = _name;
	action = _action;
	option = _option;
}

/// @func Bounding Box
/// @param {Real} _x1 X1
/// @param {Real} _x2 X2
/// @param {Real} _y1 Y1
/// @param {Real} _y2 Y2
function BoundingBox(
	_x1,
	_x2,
	_y1,
	_y2,
) constructor {
	x1 = _x1
	x2 = _x2
	y1 = _x1
	y2 = _x2
}


/// @func Menu instance
/// @param {Array<Struct.MenuItem>} _options List of options
function Menu(_options = []) constructor {
	optionSelected = 0;
	options = _options;
	filtered = false;
	overrideSize = undefined;

	/// @func Step management
	/// @param {Real} _upPressed Indicate that Up has been pressed
	/// @param {Real} _downPressed Indicate that Down has been pressed
	static step = function(_upPressed, _downPressed) {
		if (!self.filtered) {
			self.filter();
		}

		if (array_length(self.options) == 0) {
			return;
		}

		self.optionSelected += _downPressed - _upPressed;

		if (self.optionSelected >= array_length(self.options)) {
			self.optionSelected = 0;
		}

		if (self.optionSelected < 0) {
			self.optionSelected = array_length(self.options) - 1;
		}

		var _selected = self.options[self.optionSelected];

		if (_downPressed || _upPressed) {
			playSound(_selected.option.sound, 0.3);
		}
	};

	/// @func Step management
	/// @param {Real} _startX X position
	/// @param {Real} _startY Y position
	/// @param {Real} _size Y position
	/// @param {Bool} _shadow Y position
	/// @param {Bool} _enableMouse Y position
	/// @param {Bool} _cursors Y position
	/// @param {Constant.Color} _color Y position
	/// @param {Asset.GMSprite} _sprite Y position
	/// @param {Array<Real>} _yOffsets Y position
	static render = function(_startX, _startY, _size, _shadow = false, _enableMouse = true, _cursors = true, _color = c_white, _sprite = undefined, _yOffsets = undefined) {
		if (!self.filtered) {
			self.filter();
		}
		
		var _initialValign = draw_get_valign();
		var _initialHalign = draw_get_halign();

		for (var _i = 0; _i < array_length(self.options); _i++) {
			var _print = "";
			var _current = self.options[_i];
			var _opacity = 1.0;
			var _name = translate(_current.name);

			if (_i == self.optionSelected) {
				if(_cursors) {
					_print += "> " + _name + " <";
				} else {
					_print += _name;
				}
				_opacity = _current.option.selectedOpacity;
			} else {
				_print += _name;
				_opacity = _current.option.unselectedOpacity;
			}
			
			var _offsetX = _startX;
			var _offsetY = _startY + (_i * _size);
			
			if(_current.option.offsetX) {
				_offsetX += _current.option.offsetX;	
			}
			
			if(_current.option.offsetY) {
				_offsetY += _current.option.offsetY;	
			}	
			
			if(_current.option.halign) {
				draw_set_halign(_current.option.halign);
			} else {
				draw_set_halign(_initialHalign);
			}
			
			if(_current.option.valign) {
				draw_set_valign(_current.option.valign);
			} else {
				draw_set_valign(_initialValign);
			}				
			
			var _boundingBox = undefined;
			
			if(_enableMouse || _sprite) {
				_boundingBox = self.boundingBox(_offsetX, _offsetY, _size, _print, _current.option.doubleWidth, _current.option.minimalWidth);
			}
			
			if(_enableMouse) {
				self.mouse(_boundingBox, _i);
			}
			
			if(_sprite) {
				self.sprite(_boundingBox, _i, _sprite);
			}

			if (_shadow) {
				draw_set_alpha(_opacity - 0.3);

				draw_set_color(c_black);
				draw_text(_offsetX, _offsetY + 8, _print);
			}

			draw_set_alpha(_opacity);
			draw_set_color(_color);
			
			var _offsetTextY = _offsetY;
			
			if(_yOffsets != undefined && array_length(_yOffsets) == 2) {
				//_offset_text_y += (_i == self.optionSelected) ? _yOffsets[0] : _yOffsets[1];
			}

			draw_text(_offsetX, _offsetY, _print);
			draw_set_alpha(1.0);
		}

	};

	static execute = function() {
		if(array_length(self.options) > 0) {
			var _selected = self.options[self.optionSelected];

			if (_selected.action != undefined) {
				_selected.action();
			}

			playSound(_selected.option.sound, 1);
		}
	};

	/// @func Get bounding box
	/// @param {Real} _startX X position
	/// @param {Real} _startY Y position
	/// @param {Real} _size Y position
	/// @param {String} _print Y position
	/// @param {Bool} _doubleWidth Y position
	/// @param {Real} _minimalWidth Y position
	/// @return {Struct.BoundingBox}
	static boundingBox = function(_startX, _offsetY, _size, _print, _doubleWidth = false, _minimalWidth = 0) {


			var _width = max(_minimalWidth, string_width(_print));
			var _height = string_height(_print);
			
			var _halign = draw_get_halign();
			var _valign = draw_get_valign();


			var _x1 = _startX;
			var _x2 = _startX;
			var _y1 = _offsetY;
			var _y2 = _offsetY;

			switch (_halign) {
				case fa_left:
					_x2 += _width;
					if(_doubleWidth) {
						_x1 -= _width;	
					}
					break;
				case fa_center:
					_x1 -= (_width * 0.5) * (_doubleWidth ? 2 : 1);
					_x2 += (_width * 0.5) * (_doubleWidth ? 2 : 1);
					break;
				case fa_right:
					_x1 -= _width;
					if(_doubleWidth) {
						_x2 += _width;	
					}
					
			}

			switch (_valign) {
				case fa_top:
					_y2 += _height;
					break;
				case fa_middle:
					_y1 -= _height * 0.5;
					_y2 += _height * 0.5;
					break;
				case fa_bottom:
					_y1 -= _height;
					break;
			}

			// show_debug_message({_halign, _valign});
			var _rectangeOffset = _size / 10;
			_x1 -= _rectangeOffset;
			_y1 -= _rectangeOffset;
			_x2 += _rectangeOffset;
			_y2 += _rectangeOffset;

			return new BoundingBox(_x1, _x2, _y1, _y2);
		
	};
	

	/// @func Calculate mouse interaction
	/// @param {Struct.BoundingBox} _boundingBox Bounding Box
	/// @param {Real} _index Index
	static mouse = function(_boundingBox, _index) {
		
			global.mouseCursor = true;
			
			if(DEBUG) {
				draw_set_color(c_black);
				draw_rectangle(_boundingBox.x1, _boundingBox.y1, _boundingBox.x2, _boundingBox.y2, true);
			}

			if (point_in_rectangle(mouse_x, mouse_y, _boundingBox.x1, _boundingBox.y1, _boundingBox.x2, _boundingBox.y2)) {
				self.optionSelected = _index;
				
				if(mouse_check_button_pressed(mb_left)) {
					self.execute();
					global.pause = false; // Ensure pause is removed
				}
			}
		
	};
	
	/// @func Display menu sprite
	/// @param {Struct.BoundingBox} _boundingBox Bounding Box
	/// @param {Real} _index Index	
	/// @param {Asset.GMSprite} _sprite Index	
	static sprite = function(_boundingBox, _index, _sprite) {
		
			var _x1 = _boundingBox.x1;
			var _x2 = _boundingBox.x2;
			var _y1 = _boundingBox.y1;
			var _y2 = _boundingBox.y2;
			
			var _imageIndex = self.optionSelected = _index ? 1 : 0

		
			draw_sprite_stretched(
				_sprite,
				_imageIndex, 
				_x1,
				_y1,
				_x2 - _x1,
				_y2 - _y1
			);
	
		
	};
		

	static filter = function() {
		var _newOptions = [];
		/// @param {Struct.MenuItem} _element Item element

		for (
			var _optionsIndex = 0;
			_optionsIndex < array_length(self.options);
			_optionsIndex++
		) {
			var _element = self.options[_optionsIndex];

			var _len = array_length(_element.option.platforms);

			if (_len == 0) {
				array_push(_newOptions, _element);
			} else {
				var _include = false;
				for (var _platformIndex = 0; _platformIndex < _len; _platformIndex++) {
					var _platform = _element.option.platforms[_platformIndex];

					if (_platform == Platforms.DESKTOP) {
						if (
							global.platform == Platforms.LINUX
							|| global.platform == Platforms.WINDOWS
							|| global.platform == Platforms.OSX
						) {
							_include = true;
						}
					} else if (_platform == Platforms.MOBILE) {
						if (
							global.platform == Platforms.ANDROID
							|| global.platform == Platforms.IOS
							|| global.platform == Platforms.APPLE_TV
						) {
							_include = true;
						}
					} else if (_platform == Platforms.BROWSERS) {
						if (
							global.platform == Platforms.BROWSER
							|| global.platform == Platforms.GX
						) {
							_include = true;
						}
					} else if (global.platform == _platform) {
						_include = true;
					}
				}

				if (_include) {
					array_push(_newOptions, _element);
				}
			}
		}

		self.options = _newOptions;
		self.filtered = true;
	};
}

function standardMenuOptions() {
	if (!variable_global_exists("_standardOptions")) {
		global._standardOptions = {
			returnToGameSelection: new MenuItem(
				"menuSelectGame",
				returnToMenuSelection
			),
			returnToDesktopMenuItem: new MenuItem(
				"exit",
				exitToDesktop,
				new MenuItemOptions([Platforms.DESKTOP])
			),
			continueGame: new MenuItem("menuContinue", unpause),
		};
	}

	return global._standardOptions;
}

function standardMenuTitle() {
	return {
		newGame: "menuNewGame",
		start: "menuStart"
	};
}

function writeConfig() {
	ini_open(SAVE);
	ini_write_real("options", "music", global.gameOptions.music);
	ini_write_real("options", "sound", global.gameOptions.sound);
	ini_write_real("options", "fullscreen", global.gameOptions.fullscreen);	
	ini_write_string("options", "language", global.gameOptions.language);

	ini_close();

}

function toggleOptionMusic() {
	global.gameOptions.music++;
	if(global.gameOptions.music > 2) {
		global.gameOptions.music = 0;	
	}
	
	if(global.music.playing != undefined) {
		var _music = global.music.playing;
		global.music.playing = undefined;
		var _position = audio_sound_get_track_position(global.music.id);
		audio_stop_sound(_music);
		playMusic(_music, global.music.intensity);
		audio_sound_set_track_position(global.music.id, _position);
	}
	
	writeConfig();
}

function toggleOptionSound() {
	global.gameOptions.sound++;
	if(global.gameOptions.sound > 2) {
		global.gameOptions.sound = 0;	
	}
	writeConfig();
}

function toggleOptionLanguage() {
	// Dirty, but good enough for the moment
	
	if(global.gameOptions.language == "en") {
		global.gameOptions.language = "fr";	
	} else {
		global.gameOptions.language = "en";
	}
	
	setLanguage(global.gameOptions.language);
	writeConfig();
}

function toggleOptionFullScreen() {
	global.gameOptions.fullscreen = !global.gameOptions.fullscreen;
	window_set_fullscreen(global.gameOptions.fullscreen);
	writeConfig();
}
