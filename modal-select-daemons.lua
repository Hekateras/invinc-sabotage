return {
	dependents =
	{
		"skins.lua",
	},
	text_styles =
	{
	},
	skins =
	{
		{
			name = [[CheckOption]],
			isVisible = true,
			noInput = false,
			anchor = 1,
			rotation = 0,
			x = 0,
			y = 0,
			w = 0,
			h = 0,
			sx = 1,
			sy = 1,
			ctor = [[group]],
			children =
			{
				{
					name = [[widget]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = 0,
					xpx = true,
					y = 0,
					ypx = true,
					w = 294,
					wpx = true,
					h = 22,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[checkbox]],
					str = [[STR_3590571042]],
					check_size = 22,
					halign = MOAITextBox.LEFT_JUSTIFY,
					valign = MOAITextBox.LEFT_JUSTIFY,
					text_style = [[font1_16_r]],
					color =
					{
						0.549019634723663,
						1,
						1,
						1,
					},
					images =
					{
						{
							file = [[checkbox_no2.png]],
							name = [[no]],
						},
						{
							file = [[checkbox_yes2.png]],
							name = [[yes]],
						},
						{
							file = [[]],
							name = [[maybe]],
						},
					},
				},
			},
		},
	},
	widgets =
	{
		{
			name = [[bg]],
			isVisible = true,
			noInput = false,
			anchor = 0,
			rotation = 0,
			x = 0,
			y = 0,
			w = 1,
			h = 1,
			sx = 2,
			sy = 2,
			ctor = [[image]],
			color =
			{
				0,
				0,
				0,
				0.705882370471954,
			},
			images =
			{
				{
					file = [[white.png]],
					name = [[]],
					color =
					{
						0,
						0,
						0,
						0.705882370471954,
					},
				},
			},
		},
		{
			name = [[panel]],
			isVisible = true,
			noInput = false,
			anchor = 0,
			rotation = 0,
			x = 0,
			y = 0,
			w = 0,
			h = 0,
			sx = 1,
			sy = 1,
			ctor = [[group]],
			children =
			{
				{
					name = [[bg 2]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = 0,
					xpx = true,
					y = -6,
					ypx = true,
					w = 400,
					wpx = true,
					h = 300,
					hpx = true,
					sx = 1,
					sy = 1.3,
					ctor = [[image]],
					color =
					{
						0.0784313753247261,
						0.0784313753247261,
						0.0784313753247261,
						0.901960790157318,
					},
					images =
					{
						{
							file = [[white.png]],
							name = [[]],
							color =
							{
								0.0784313753247261,
								0.0784313753247261,
								0.0784313753247261,
								0.901960790157318,
							},
						},
					},
				},
				{
					name = [[bg 2 2]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = 0,
					xpx = true,
					y = 12,
					ypx = true,
					w = 300,
					wpx = true,
					h = 274,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[image]],
					color =
					{
						0,
						0,
						0,
						0.901960790157318,
					},
					images =
					{
						{
							file = [[white.png]],
							name = [[]],
							color =
							{
								0,
								0,
								0,
								0.901960790157318,
							},
						},
					},
				},
				{
					name = [[header_box]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = 0,
					xpx = true,
					y = 194,
					ypx = true,
					w = 400,
					wpx = true,
					h = 14,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[image]],
					color =
					{
						0.549019634723663,
						1,
						1,
						0.588235318660736,
					},
					images =
					{
						{
							file = [[white.png]],
							name = [[]],
							color =
							{
								0.549019634723663,
								1,
								1,
								0.588235318660736,
							},
						},
					},
				},
				
				{
					name = [[headerTxt]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = 1,
					xpx = true,
					y = 149,
					ypx = true,
					w = 380,
					wpx = true,
					h = 54,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[label]],
					halign = MOAITextBox.CENTER_JUSTIFY,
					valign = MOAITextBox.LEFT_JUSTIFY,
					text_style = [[font1_14_r]],
					color =
					{
						0.549019634723663,
						1,
						1,
						1,
					},
					rawstr = "",
				},
				{
					name = [[header box 2]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = 2,
					xpx = true,
					y = 159,
					ypx = true,
					w = 380,
					wpx = true,
					h = 1,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[image]],
					color =
					{
						0.549019634723663,
						1,
						1,
						0.588235318660736,
					},
					images =
					{
						{
							file = [[white.png]],
							name = [[]],
							color =
							{
								0.549019634723663,
								1,
								1,
								0.588235318660736,
							},
						},
					},
				},
				{
					name = [[okBtn]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = 0,
					xpx = true,
					y = -183,
					ypx = true,
					w = 300,
					wpx = true,
					h = 20,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[button]],
					clickSound = [[SpySociety/HUD/menu/cancel]],
					hoverSound = [[SpySociety/HUD/menu/rollover]],
					hoverScale = 1,
					str = [[STR_2257412423]], -- CONTINUE
					hotkey = 27,
					halign = MOAITextBox.CENTER_JUSTIFY,
					valign = MOAITextBox.CENTER_JUSTIFY,
					text_style = [[font1_16_r]],
					images =
					{
						{
							file = [[white.png]],
							name = [[inactive]],
							color =
							{
								0.219607844948769,
								0.376470595598221,
								0.376470595598221,
								1,
							},
						},
						{
							file = [[white.png]],
							name = [[hover]],
							color =
							{
								0.39215686917305,
								0.690196096897125,
								0.690196096897125,
								1,
							},
						},
						{
							file = [[white.png]],
							name = [[active]],
							color =
							{
								0.39215686917305,
								0.690196096897125,
								0.690196096897125,
								1,
							},
						},
					},
				},
				{
					name = [[list]],
					isVisible = true,
					noInput = false,
					anchor = 1,
					rotation = 0,
					x = -2,
					xpx = true,
					y = 12,
					ypx = true,
					w = 296,
					wpx = true,
					h = 270,
					hpx = true,
					sx = 1,
					sy = 1,
					ctor = [[listbox]],
					item_template = [[generation_option]],
					scrollbar_template = [[listbox_vscroll]],
					orientation = 2,
					item_spacing = 24,
					no_hitbox = true,
				},
			},
		},
	},
	transitions =
	{
	},
	properties =
	{
		sinksInput = true,
		activateTransition = [[activate_below]],
		deactivateTransition = [[deactivate_below]],
	}
}
