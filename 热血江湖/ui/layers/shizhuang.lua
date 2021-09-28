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
			name = "jdk",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "padtop",
				varName = "padtop",
				posX = 0.5,
				posY = 0.9406416,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 0.1152778,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				alphaCascade = true,
				layoutType = 8,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "uu2",
					posX = 0.1849927,
					posY = 0.5602064,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2257813,
					sizeY = 0.7710842,
					image = "ty#pad2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "uu1",
					posX = 0.169735,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07265625,
					sizeY = 0.445783,
					image = "bg2#shiz",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "aa",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				layoutType = 5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wp1",
					varName = "ingotRoot",
					posX = 0.2490764,
					posY = 0.9466151,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1974032,
					sizeY = 0.09027778,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "sdf",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6886286,
						sizeY = 0.7230768,
						image = "tong#sld",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl1",
						varName = "diamond",
						posX = 0.4952299,
						posY = 0.4789422,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.456257,
						sizeY = 0.8239378,
						text = "3421万",
						color = "FFF4CA64",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF804000",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "cz",
						varName = "add_diamond",
						posX = 0.4890573,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7707335,
						sizeY = 0.9438011,
						alphaCascade = true,
						disablePressScale = true,
						propagateToChildren = true,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "tp",
							posX = 0.8633726,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2567448,
							sizeY = 0.7824333,
							image = "tong#jia",
							imageNormal = "tong#jia",
							disableClick = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "FrameAni",
						name = "yb",
						sizeXAB = 55.76301,
						sizeYAB = 58.5916,
						posXAB = 53.01218,
						posYAB = 31.27226,
						posX = 0.2098029,
						posY = 0.4811117,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2206897,
						sizeY = 0.9014091,
						effect = "21",
						alpha = 0,
						frameEnd = 16,
						frameName = "uieffect/yuanbao.png",
						delay = 0.1,
						frameWidth = 64,
						frameHeight = 64,
						column = 4,
						repeatLastFrame = 15,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wp2",
					varName = "ingotLockRoot",
					posX = 0.4186115,
					posY = 0.9466151,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1974032,
					sizeY = 0.09027779,
					scale9 = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "sdf2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6886286,
						sizeY = 0.7230768,
						image = "tong#sld",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl2",
						varName = "diamondLock",
						posX = 0.4952299,
						posY = 0.4789422,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.456257,
						sizeY = 0.8239378,
						text = "22亿",
						color = "FFF4CA64",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF804000",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "syb",
						posX = 0.2098029,
						posY = 0.4811117,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.21767,
						sizeY = 0.8461537,
						image = "uieffect/01.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo1",
							posX = 0.6747323,
							posY = 0.3538701,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.46875,
							sizeY = 0.4687499,
							image = "tb#tb_suo.png",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wp3",
					varName = "coinRoot",
					posX = 0.5881464,
					posY = 0.9466151,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1974032,
					sizeY = 0.09027779,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "sdf3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6886287,
						sizeY = 0.7230768,
						image = "tong#sld",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl3",
						varName = "coin",
						posX = 0.4952299,
						posY = 0.4789422,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.456257,
						sizeY = 0.8239378,
						text = "10.3万",
						color = "FFF4CA64",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF804000",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "cz2",
						varName = "add_coin",
						posX = 0.4890573,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7707335,
						sizeY = 0.9438011,
						disablePressScale = true,
						propagateToChildren = true,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "j2",
							posX = 0.8633726,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2567448,
							sizeY = 0.7824333,
							image = "tong#jia",
							imageNormal = "tong#jia",
							disablePressScale = true,
							disableClick = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tq",
						posX = 0.2098029,
						posY = 0.4811117,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.21767,
						sizeY = 0.8461537,
						image = "uieffect/tq.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wp4",
					varName = "coinLockRoot",
					posX = 0.7576817,
					posY = 0.9466151,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1974032,
					sizeY = 0.09027779,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "sdf4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6886287,
						sizeY = 0.7230768,
						image = "tong#sld",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl4",
						varName = "coinLock",
						posX = 0.4952299,
						posY = 0.4789422,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.456257,
						sizeY = 0.8239378,
						text = "9942万",
						color = "FFF4CA64",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF804000",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "stq",
						posX = 0.2098029,
						posY = 0.4811117,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.21767,
						sizeY = 0.8461537,
						image = "uieffect/tq.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo2",
							posX = 0.7009149,
							posY = 0.3206291,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.4687501,
							sizeY = 0.46875,
							image = "tb#tb_suo.png",
						},
					},
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
				etype = "Image",
				name = "z2",
				posX = 0.7137104,
				posY = 0.4590964,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4274222,
				sizeY = 0.8333525,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.4670997,
					posY = 0.4966401,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9047699,
					sizeY = 0.7537235,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "bglb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.99,
						sizeY = 0.99,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsz",
						posX = 0.5,
						posY = 0.02872656,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9802843,
						sizeY = 0.04260502,
						scale9 = true,
						scale9Left = 0.3,
						scale9Right = 0.3,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tsz",
						varName = "desc_1",
						posX = 0.5043213,
						posY = -0.04953123,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.7256222,
						sizeY = 0.1702153,
						text = "只有精纺过的披风方可放入衣橱",
						color = "FFC93034",
						hTextAlign = 1,
						vTextAlign = 1,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tsz2",
							varName = "desc_2",
							posX = 0.5,
							posY = 0.1102821,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							text = "衣橱内的披风会追加人物属性",
							color = "FFC93034",
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
					etype = "Button",
					name = "yjzb",
					varName = "recover_btn",
					posX = 0.1918262,
					posY = 0.05478044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3180403,
					sizeY = 0.1099975,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ys2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9120977,
						sizeY = 1.156784,
						text = "还 原",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB35F1D",
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
					name = "plcs",
					varName = "store_btn",
					posX = 0.7495553,
					posY = 0.05478044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3180403,
					sizeY = 0.1099975,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ys3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9120977,
						sizeY = 1.156784,
						text = "商 城",
						fontSize = 24,
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
				etype = "Image",
				name = "z1",
				posX = 0.2785207,
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
					posX = 0.5176472,
					posY = 0.454756,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8862745,
					sizeY = 0.7145271,
					image = "yxbj#yxbj",
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dfas",
						posX = 0.5044184,
						posY = 1.172401,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6172566,
						sizeY = 0.1182033,
						image = "chu1#zld",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "zl",
							varName = "battle_power",
							posX = 0.5930341,
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
					{
						prop = {
							etype = "Label",
							name = "dj",
							varName = "role_lv",
							posX = 0.03907025,
							posY = -0.6424803,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5063323,
							sizeY = 1.169878,
							text = "LV99",
							color = "FFFFEED7",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB2722C",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
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
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mzd",
					posX = 0.2670473,
					posY = 0.7723779,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09215686,
					sizeY = 0.0793919,
					image = "bgchu#zyd",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "mz",
						varName = "job",
						posX = 0.5,
						posY = -1.200322,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6083622,
						sizeY = 2.304173,
						text = "刀客",
						color = "FF966856",
						fontSize = 24,
						fontOutlineColor = "FF512913",
						hTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zy2",
						varName = "class_icon",
						posX = 0.5,
						posY = 0.5285904,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9574469,
						sizeY = 0.9574469,
						image = "zy#daoke",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zb1",
					varName = "equip1",
					posX = 0.1099252,
					posY = 0.7741183,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1839434,
					sizeY = 0.1531827,
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd1",
						varName = "grade_icon1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.011957,
						sizeY = 1.037429,
						image = "bg2#3",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt1",
						varName = "equip_icon1",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz1",
						varName = "qh_level1",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ts1",
						varName = "tips1",
						posX = 0.8517831,
						posY = 0.885722,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2878123,
						sizeY = 0.308764,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzt1",
						varName = "is_select1",
						posX = 0.5,
						posY = 0.5432262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.10861,
						sizeY = 1.146838,
						image = "djk#zbxz",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzb1",
						varName = "repair1",
						posX = 0.7232507,
						posY = 0.3181197,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3411109,
						sizeY = 0.3528731,
						image = "bg2#chuizi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zb2",
					varName = "equip3",
					posX = 0.1099252,
					posY = 0.5747927,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1839434,
					sizeY = 0.1531827,
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd2",
						varName = "grade_icon3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.011957,
						sizeY = 1.037429,
						image = "bg2#3",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt2",
						varName = "equip_icon3",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz2",
						varName = "qh_level3",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ts2",
						varName = "tips3",
						posX = 0.8517831,
						posY = 0.885722,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2878123,
						sizeY = 0.308764,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzt2",
						varName = "is_select3",
						posX = 0.5,
						posY = 0.5432262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.10861,
						sizeY = 1.146838,
						image = "djk#zbxz",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzb2",
						varName = "repair3",
						posX = 0.7232507,
						posY = 0.3181197,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3411109,
						sizeY = 0.3528731,
						image = "bg2#chuizi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zb5",
					varName = "equip2",
					posX = 0.9261733,
					posY = 0.7741183,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1839434,
					sizeY = 0.1531827,
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd5",
						varName = "grade_icon2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.011957,
						sizeY = 1.037429,
						image = "bg2#7",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt5",
						varName = "equip_icon2",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz5",
						varName = "qh_level2",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ts5",
						varName = "tips2",
						posX = 0.8517831,
						posY = 0.8857223,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2878123,
						sizeY = 0.308764,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzt5",
						varName = "is_select2",
						posX = 0.5,
						posY = 0.5432262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.10861,
						sizeY = 1.146838,
						image = "djk#zbxz",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzb5",
						varName = "repair2",
						posX = 0.7232507,
						posY = 0.3181197,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3411109,
						sizeY = 0.3528731,
						image = "bg2#chuizi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx2",
					varName = "hero_module",
					posX = 0.5157157,
					posY = 0.2372019,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6187299,
					sizeY = 0.5545572,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xz",
					varName = "revolve",
					posX = 0.5,
					posY = 0.48491,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6757718,
					sizeY = 0.6560169,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "logo",
					varName = "LogoImage",
					posX = 0.5157157,
					posY = 0.1509119,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3921569,
					sizeY = 0.03885135,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "dxpf",
					varName = "dxpf",
					posX = 0.9261733,
					posY = 0.4263647,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2472279,
					sizeY = 0.4883357,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "plcs2",
						varName = "liulan_btn",
						posX = 0.5,
						posY = 0.134904,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6106932,
						sizeY = 0.2732669,
						image = "bgchu#zs",
						imageNormal = "bgchu#zs",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bq1",
						varName = "qua1",
						posX = 0.4920801,
						posY = 0.8867822,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.070696,
						sizeY = 0.1210676,
						image = "bgchu#chuanshuo",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bq2",
						varName = "qua2",
						posX = 0.4920801,
						posY = 0.7428911,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.070696,
						sizeY = 0.1210676,
						image = "bgchu#chuanshuo",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bq3",
						varName = "qua3",
						posX = 0.4920801,
						posY = 0.5990001,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.070696,
						sizeY = 0.1210676,
						image = "bgchu#chuanshuo",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bq4",
						varName = "qua4",
						posX = 0.4920801,
						posY = 0.4551091,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.070696,
						sizeY = 0.1210676,
						image = "bgchu#chuanshuo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "kuai",
					varName = "weaponShowRoot",
					posX = 0.5,
					posY = 0.1468186,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6385776,
					sizeY = 0.08094858,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wqwx",
						posX = 0.3900151,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6314029,
						sizeY = 1.145814,
						text = "武器形象",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tj2",
						posX = 0.6443149,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5097113,
						sizeY = 1.001637,
						image = "b#srk",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "dj3",
							varName = "gradeBtn2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							disablePressScale = true,
							propagateToChildren = true,
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "jih2",
								varName = "chooseTypeBtn1",
								posX = 0.8978875,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.2590362,
								sizeY = 0.9166666,
								image = "pmh#jiantou",
								imageNormal = "pmh#jiantou",
								disableClick = true,
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wz2",
							varName = "showTypeText1",
							posX = 0.4174764,
							posY = 0.5221087,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7650473,
							sizeY = 1,
							text = "武器",
							color = "FFFFF0D5",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "fl4",
						varName = "showTypeBg1",
						posX = 0.6449873,
						posY = 1.071989,
						anchorX = 0.5,
						anchorY = 0,
						sizeX = 0.5102462,
						sizeY = 4.240478,
						image = "b#bp",
						scale9 = true,
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb2",
							varName = "showTypeScroll1",
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
					etype = "Grid",
					name = "kuai2",
					varName = "skinShowRoot",
					posX = 0.5,
					posY = 0.05222369,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6385776,
					sizeY = 0.08094858,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wqwx2",
						posX = 0.3900151,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6314029,
						sizeY = 1.145814,
						text = "外观形象",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tj3",
						posX = 0.6443149,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5097113,
						sizeY = 1.001637,
						image = "b#srk",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "dj4",
							varName = "gradeBtn3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							disablePressScale = true,
							propagateToChildren = true,
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "jih3",
								varName = "chooseTypeBtn2",
								posX = 0.8978875,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.2590362,
								sizeY = 0.9166666,
								image = "pmh#jiantou",
								imageNormal = "pmh#jiantou",
								disableClick = true,
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wz3",
							varName = "showTypeText2",
							posX = 0.4174764,
							posY = 0.5221087,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7650473,
							sizeY = 1,
							text = "胸甲",
							color = "FFFFF0D5",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "fl5",
						varName = "showTypeBg2",
						posX = 0.6449873,
						posY = 1.071989,
						anchorX = 0.5,
						anchorY = 0,
						sizeX = 0.5102462,
						sizeY = 3.221127,
						image = "b#bp",
						scale9 = true,
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb3",
							varName = "showTypeScroll2",
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
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh8",
				varName = "fashion_btn",
				posX = 0.9319386,
				posY = 0.5672125,
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
					name = "dsa2",
					posX = 0.4995593,
					posY = 0.500794,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.809434,
					text = "披风",
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
					name = "xhd2",
					varName = "sz_redPoint",
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
				etype = "Button",
				name = "qh9",
				varName = "bag_btn",
				posX = 0.9319386,
				posY = 0.7267957,
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
					name = "dsa",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "背包",
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
					name = "xhd",
					varName = "red_point",
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
				etype = "Button",
				name = "qh11",
				varName = "role_btn",
				posX = 0.9319386,
				posY = 0.4076294,
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
					posX = 0.4995593,
					posY = 0.500794,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.809434,
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
				etype = "Button",
				name = "qh10",
				varName = "warehouse_btn",
				posX = 0.9319386,
				posY = 0.2480462,
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
					name = "dsa3",
					posX = 0.4995593,
					posY = 0.500794,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.809434,
					text = "仓库",
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
					name = "xhd3",
					varName = "sz_redPoint2",
					posX = 0.6680423,
					posY = 0.791844,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3292683,
					sizeY = 0.1985816,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh4",
				varName = "weapon_btn",
				posX = 0.651484,
				posY = 0.8156386,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09215988,
				sizeY = 0.08055556,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.90999,
					sizeY = 0.8281401,
					text = "武 器",
					color = "FF966856",
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
				name = "qh5",
				varName = "image_btn",
				posX = 0.5553178,
				posY = 0.8156385,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09215988,
				sizeY = 0.08055556,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.90999,
					sizeY = 0.8281401,
					text = "形 象",
					color = "FF966856",
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
					name = "rsa",
					posX = 0.471938,
					posY = 0.6473824,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4859813,
					sizeY = 0.2506964,
					image = "bg2#shiz",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "padzs",
				varName = "padzs",
				posX = 0.05545116,
				posY = 0.8730147,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.028125,
				sizeY = 0.1,
				image = "ty#pad1",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh6",
				varName = "storage_btn",
				posX = 0.8438165,
				posY = 0.8156386,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09215988,
				sizeY = 0.08055556,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.90999,
					sizeY = 0.8281401,
					text = "衣 橱",
					color = "FF966856",
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
				name = "qh7",
				varName = "huanXing_btn",
				posX = 0.7476501,
				posY = 0.8156386,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09215988,
				sizeY = 0.08055556,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz4",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.90999,
					sizeY = 0.8281401,
					text = "幻 形",
					color = "FF966856",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
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
	tc = {
		zb1 = {
			rotate = {{0, {0}}, {500, {300}}, },
		},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
