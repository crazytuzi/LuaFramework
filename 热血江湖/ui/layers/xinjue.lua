--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "kk1",
				posX = 0.5,
				posY = 0.4577084,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9078125,
				sizeY = 0.8763889,
				image = "b#db1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zs1",
					posX = 0.02057244,
					posY = 0.1628659,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05421687,
					sizeY = 0.3755943,
					image = "zhu#zs1",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs2",
					posX = 0.9442027,
					posY = 0.1851488,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1592083,
					sizeY = 0.4057052,
					image = "zhu#zs2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db2",
					posX = 0.491394,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9363167,
					sizeY = 0.9746434,
					image = "b#db2",
					scale9 = true,
					scale9Left = 0.47,
					scale9Right = 0.47,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "title",
					posX = 0.5,
					posY = 0.9873216,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.07401,
					sizeY = 0.08082409,
					image = "b#top",
					scale9 = true,
					scale9Left = 0.49,
					scale9Right = 0.49,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh7",
				varName = "role_btn",
				posX = 0.9319386,
				posY = 0.7267956,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07734375,
				sizeY = 0.2125,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "yq",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "属性",
					color = "FFEBC6B4",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z1",
				posX = 0.2699275,
				posY = 0.4534763,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3984375,
				sizeY = 0.8222222,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dw1",
					posX = 0.5430939,
					posY = 0.5188743,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.082353,
					sizeY = 0.9915541,
					image = "xinjue#dw",
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zldd",
						posX = 0.5261248,
						posY = 0.04645598,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5054348,
						sizeY = 0.08517888,
						image = "chu1#zld",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "zl",
							varName = "level_txt",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7138616,
							sizeY = 1.061954,
							text = "455546",
							color = "FFFFE7AF",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB2722C",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
							colorTL = "FFFFD060",
							colorTR = "FFFFD060",
							colorBR = "FFF2441C",
							colorBL = "FFF2441C",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xz",
					varName = "revolve",
					posX = 0.5685041,
					posY = 0.4832235,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6757718,
					sizeY = 0.6560169,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnk",
					posX = 0.2104681,
					posY = 0.8373967,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1901961,
					sizeY = 0.1469595,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jnt",
						varName = "skill_img1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.020619,
						sizeY = 1.229885,
						image = "xinjue#yulong",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn1",
						varName = "skill_btn1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnk2",
					posX = 0.963885,
					posY = 0.8390751,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1901961,
					sizeY = 0.1469595,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jnt2",
						varName = "skill_img2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.020619,
						sizeY = 1.229885,
						image = "xinjue#yulong",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn2",
						varName = "skill_btn2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnk3",
					posX = 0.2104681,
					posY = 0.5827812,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1901961,
					sizeY = 0.1469595,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jnt3",
						varName = "skill_img3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.020619,
						sizeY = 1.229885,
						image = "xinjue#yulong",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn3",
						varName = "skill_btn3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnk4",
					posX = 0.963885,
					posY = 0.5836204,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1901961,
					sizeY = 0.1469595,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jnt4",
						varName = "skill_img4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.020619,
						sizeY = 1.229885,
						image = "xinjue#yulong",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn4",
						varName = "skill_btn4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnk5",
					posX = 0.2104681,
					posY = 0.3281657,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1901961,
					sizeY = 0.1469595,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jnt5",
						varName = "skill_img5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.020619,
						sizeY = 1.229885,
						image = "xinjue#yulong",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn5",
						varName = "skill_btn5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnk6",
					posX = 0.963885,
					posY = 0.3281657,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1901961,
					sizeY = 0.1469595,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "jnt6",
						varName = "skill_img6",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.020619,
						sizeY = 1.229885,
						image = "xinjue#yulong",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn6",
						varName = "skill_btn6",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh10",
				varName = "roleTitle_btn",
				posX = 0.9319386,
				posY = 0.5678637,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07734375,
				sizeY = 0.2125,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dsa4",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "称号",
					color = "FFEBC6B4",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh11",
				varName = "reqBtn",
				posX = 0.9319386,
				posY = 0.4089319,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07734375,
				sizeY = 0.2125,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dsa5",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "声望",
					color = "FFEBC6B4",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh12",
				varName = "xinjueBtn",
				posX = 0.9319386,
				posY = 0.25,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07734375,
				sizeY = 0.2125,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dsa6",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "心诀",
					color = "FFEBC6B4",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "xj_red",
					posX = 0.7694741,
					posY = 0.7978233,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2727273,
					sizeY = 0.1830065,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				varName = "hero_module",
				posX = 0.3003834,
				posY = 0.294257,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2465252,
				sizeY = 0.4559692,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.9274268,
				posY = 0.8660722,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sjtop",
				varName = "sjtop",
				posX = 0.04916242,
				posY = 0.6358366,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08359375,
				sizeY = 0.4986111,
				image = "tong#denglong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tsa",
					posX = 0.471938,
					posY = 0.6473824,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4859813,
					sizeY = 0.2423398,
					image = "bg2#xinjue",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "xiuxin",
				varName = "xiuxin",
				posX = 0.6996472,
				posY = 0.4570198,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4227062,
				sizeY = 0.8054716,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bgt",
					posX = 0.5,
					posY = 0.9398559,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5156507,
					sizeY = 0.08621588,
					image = "chu1#zld",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zl2",
						varName = "xiuxin_zhanli",
						posX = 0.5930341,
						posY = 0.46,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7138616,
						sizeY = 1.061954,
						text = "455546",
						color = "FFFFE7AF",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB2722C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
						colorTL = "FFFFD060",
						colorTR = "FFFFD060",
						colorBR = "FFF2441C",
						colorBL = "FFF2441C",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zhanz",
						posX = 0.2564197,
						posY = 0.5043473,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.125448,
						sizeY = 0.6400001,
						image = "tong#zl",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw",
					posX = 0.5,
					posY = 0.6239411,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8297202,
					sizeY = 0.5233334,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "props_content",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9825092,
						sizeY = 0.9752496,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d4",
					posX = 0.5,
					posY = 0.2288494,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8297202,
					sizeY = 0.2393083,
					image = "b#d4",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lie",
						varName = "material_content",
						posX = 0.5000001,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9360904,
						sizeY = 0.8395374,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "plcs2",
					varName = "xiuxin_btn",
					posX = 0.5,
					posY = 0.05133179,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2874806,
					sizeY = 0.1017347,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ys4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9120977,
						sizeY = 1.156784,
						text = "修 心",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "tupo",
				varName = "tupo",
				posX = 0.6996472,
				posY = 0.4570198,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.4227062,
				sizeY = 0.8054716,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bgt2",
					posX = 0.5,
					posY = 0.9398559,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6656673,
					sizeY = 0.08621588,
					image = "chu1#zld",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zl3",
						varName = "battle_power3",
						posX = 0.2562344,
						posY = 0.4600012,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5713661,
						sizeY = 1.061954,
						text = "即将突破：",
						color = "FFFFE7AF",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB2722C",
						fontOutlineSize = 2,
						hTextAlign = 2,
						vTextAlign = 1,
						colorTL = "FFFFD060",
						colorTR = "FFFFD060",
						colorBR = "FFF2441C",
						colorBL = "FFF2441C",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zl4",
						varName = "nextLevel",
						posX = 0.7121372,
						posY = 0.4600006,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4074742,
						sizeY = 1.061954,
						text = "二重",
						color = "FFFFE7AF",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB2722C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
						colorTL = "FFFFD060",
						colorTR = "FFFFD060",
						colorBR = "FFF2441C",
						colorBL = "FFF2441C",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw2",
					posX = 0.5,
					posY = 0.5989832,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8297202,
					sizeY = 0.4734178,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "tupo_content",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9825092,
						sizeY = 0.9752496,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d5",
					posX = 0.5,
					posY = 0.2288494,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8297202,
					sizeY = 0.2393083,
					image = "b#d4",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lie2",
						varName = "tupo_mats",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9360904,
						sizeY = 0.8395374,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "plcs3",
					varName = "tupo_btn",
					posX = 0.5,
					posY = 0.05133179,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2874806,
					sizeY = 0.1017347,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ys5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9120977,
						sizeY = 1.156784,
						text = "突破",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xzj",
					posX = 0.6900529,
					posY = 0.8646085,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1611576,
					text = "等级限制：",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xzj2",
					varName = "levelLimit",
					posX = 0.7819585,
					posY = 0.8646085,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4161888,
					sizeY = 0.1611576,
					text = "90",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xzj3",
					varName = "successRate",
					posX = 0.4571828,
					posY = 0.05204305,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4161888,
					sizeY = 0.1611576,
					text = "50%",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xzj4",
					posX = 0.3893039,
					posY = 0.05204305,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1611576,
					text = "成功率：",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xzj5",
					varName = "successTime",
					posX = 0.7049001,
					posY = 0.05204305,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4207018,
					sizeY = 0.1611576,
					text = "10次必然成功",
					color = "FF966856",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "max",
				varName = "max",
				posX = 0.6996472,
				posY = 0.4570198,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.4227062,
				sizeY = 0.8054716,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bgt3",
					posX = 0.5,
					posY = 0.9398559,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5156507,
					sizeY = 0.08621588,
					image = "chu1#zld",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zl5",
						varName = "max_zhanli",
						posX = 0.5930341,
						posY = 0.46,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7138616,
						sizeY = 1.061954,
						text = "455546",
						color = "FFFFE7AF",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB2722C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
						colorTL = "FFFFD060",
						colorTR = "FFFFD060",
						colorBR = "FFF2441C",
						colorBL = "FFF2441C",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zhanz2",
						posX = 0.2564197,
						posY = 0.5043473,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.125448,
						sizeY = 0.6400001,
						image = "tong#zl",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw3",
					posX = 0.5,
					posY = 0.6494455,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8297202,
					sizeY = 0.4606969,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb3",
						varName = "max_content",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9825092,
						sizeY = 0.9752496,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "dh",
					posX = 0.5052565,
					posY = 0.2171125,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8755196,
					sizeY = 0.5543582,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dg",
						posX = 0.4869009,
						posY = 0.5000016,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6344997,
						sizeY = 0.9115104,
						image = "top#top_dg.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "max2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7198666,
						sizeY = 0.842091,
						image = "top#top_d1.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "mm",
							posX = 0.4832723,
							posY = 0.5140469,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3735865,
							sizeY = 0.2598678,
							image = "top#top_max.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "x1",
							posX = 0.2501217,
							posY = 0.395598,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1051091,
							sizeY = 0.1337574,
							image = "top#top_xx.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "x2",
							posX = 0.3202535,
							posY = 0.7589161,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.07791215,
							sizeY = 0.09914774,
							image = "top#top_xx.png",
							alpha = 0.6,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "x3",
							posX = 0.6137581,
							posY = 0.6516484,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.09966308,
							sizeY = 0.1268271,
							image = "top#top_xx.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "x4",
							posX = 0.7072654,
							posY = 0.3056266,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1431648,
							sizeY = 0.1821855,
							image = "top#top_xx.png",
							alpha = 0.8,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "x5",
							posX = 0.4397338,
							posY = 0.2364247,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.06703404,
							sizeY = 0.08530471,
							image = "top#top_xx.png",
							alpha = 0.7,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian1",
							posX = 0.06831103,
							posY = 0.3695921,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.03833021,
							sizeY = 0.04974475,
							image = "top#top_xx2.png",
							alpha = 0.3,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian2",
							posX = 0.003378459,
							posY = 0.7502149,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.04698094,
							sizeY = 0.06097163,
							image = "top#top_xx2.png",
							alpha = 0.25,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian3",
							posX = 0.06311565,
							posY = 0.8817009,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.05433132,
							sizeY = 0.07051091,
							image = "top#top_xx2.png",
							alpha = 0.32,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian4",
							posX = 0.2189608,
							posY = 0.9024621,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.04366454,
							sizeY = 0.05666763,
							image = "top#top_xx2.png",
							alpha = 0.63,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian5",
							posX = 0.2968734,
							posY = 0.6533246,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.0576539,
							sizeY = 0.07482296,
							image = "top#top_xx2.png",
							alpha = 0.63,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian6",
							posX = 0.5280461,
							posY = 0.937062,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1109687,
							sizeY = 0.1440147,
							image = "top#top_xx2.png",
							alpha = 0.22,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian7",
							posX = 0.7436307,
							posY = 0.9370661,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.03098417,
							sizeY = 0.04021113,
							image = "top#top_xx2.png",
							alpha = 0.5,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian8",
							posX = 0.7436336,
							posY = 0.667172,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.04165776,
							sizeY = 0.05406327,
							image = "top#top_xx2.png",
							alpha = 0.46,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian9",
							posX = 0.8968775,
							posY = 0.4837845,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.03633073,
							sizeY = 0.04714987,
							image = "top#top_xx2.png",
							alpha = 0.26,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dian10",
							posX = 0.8553202,
							posY = 0.2138905,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.07899269,
							sizeY = 0.1025164,
							image = "top#top_xx2.png",
							alpha = 0.7,
						},
					},
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bz",
				varName = "help_btn",
				posX = 0.9367821,
				posY = 0.1034441,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04765625,
				sizeY = 0.09166667,
				image = "tong#bz",
				imageNormal = "tong#bz",
				disablePressScale = true,
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	max = {
		dh = {
			scale = {{0, {0, 0, 1}}, {300, {1.1, 1.1, 1}}, {400, {1,1,1}}, },
		},
	},
	xzh = {
		dg = {
			rotate = {{0, {0}}, {4000, {180}}, },
		},
		x1 = {
			alpha = {{0, {1}}, {600, {0.5}}, {1600, {0.8}}, {2500, {1}}, },
		},
		x2 = {
			alpha = {{0, {0.6}}, {600, {1}}, {1600, {0.8}}, {2500, {0.6}}, },
		},
		x3 = {
			alpha = {{0, {1}}, {600, {0.5}}, {1600, {0.8}}, {2500, {1}}, },
		},
		x4 = {
			alpha = {{0, {0.8}}, {600, {0.6}}, {1600, {1}}, {2500, {0.8}}, },
		},
		x5 = {
			alpha = {{0, {0.7}}, {600, {0.3}}, {1600, {0.5}}, {2500, {0.7}}, },
		},
	},
	c_dakai = {
		{0,"max", 1, 0},
		{0,"xzh", -1, 400},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
