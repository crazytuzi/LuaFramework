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
			alpha = 0.8,
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
			varName = "root",
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
				name = "gdylbj1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "gdylbj1#gdylbj1",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.261084,
					sizeY = 1.241379,
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
						visible = false,
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
						visible = false,
						sizeX = 0.1592083,
						sizeY = 0.4057052,
						image = "zhu#zs2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "db2",
						posX = 0.4981442,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9363168,
						sizeY = 0.959002,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "yuanling",
				varName = "fragmentRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "ylbj",
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
						name = "ab",
						posX = 0.2959006,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5124596,
						sizeY = 0.8761463,
					},
					children = {
					{
						prop = {
							etype = "Sprite3D",
							name = "yl",
							varName = "monsterModel",
							posX = 0.557583,
							posY = -0.04806828,
							anchorX = 0.5,
							anchorY = 0.05,
							sizeX = 0.6429924,
							sizeY = 0.9636376,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "xz",
							varName = "revolve",
							posX = 0.5172757,
							posY = 0.3855685,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7236069,
							sizeY = 0.9636375,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mz",
							varName = "monsterName",
							posX = 0.2082839,
							posY = 0.1798901,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.07101813,
							sizeY = 0.3340844,
							text = "怪名字",
							color = "FFBC541E",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFFDF2BA",
							fontOutlineSize = 2,
							hTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "th",
							posX = 0.2082838,
							posY = -0.03237209,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.09997184,
							sizeY = 0.102329,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb1",
							varName = "skillList",
							posX = 0.06353115,
							posY = 0.2571379,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1345775,
							sizeY = 0.6586093,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb2",
							posX = -0.07104652,
							posY = 0.2210444,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.1345775,
							sizeY = 0.5903596,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an1",
							varName = "randomModelBtn",
							posX = 0.2082838,
							posY = -0.03237209,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.09997184,
							sizeY = 0.102329,
							image = "guidaoyuling1#sx",
							imageNormal = "guidaoyuling1#sx",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sx",
						posX = 0.7129501,
						posY = 0.4139338,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.239016,
						sizeY = 0.4854086,
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lie",
							varName = "fragmentList",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.071718,
							sizeY = 0.974416,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb",
							varName = "noFragment",
							posX = 0.5,
							posY = 0.4744778,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.168725,
							sizeY = 0.2325395,
							text = "无",
							color = "FFFFC045",
							fontSize = 22,
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
					etype = "RichText",
					name = "wb1",
					varName = "yulingTime",
					posX = 0.7853643,
					posY = 0.1062284,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3777048,
					sizeY = 0.06994069,
					text = "每日可进行10次驭灵",
					color = "FFFFC045",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wb3",
					varName = "canNot",
					posX = 0.7853643,
					posY = 0.05637606,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3777048,
					sizeY = 0.06994069,
					text = "当前无法获得碎片",
					color = "FFFFC045",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb5",
					posX = 0.009702738,
					posY = 0.4896721,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04622842,
					sizeY = 0.25,
					text = "捕捉顺序",
					color = "FFFF8545",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "lianhua",
				varName = "lianHuaRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "lhbj",
					posX = 0.4980336,
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
						name = "sx2",
						posX = 0.7129501,
						posY = 0.4139338,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.239016,
						sizeY = 0.4854086,
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lie2",
							varName = "lianHuaBagList",
							posX = 0.5082269,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.071718,
							sizeY = 0.974416,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb4",
							varName = "noFragment2",
							posX = 0.5082273,
							posY = 0.4744778,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.168725,
							sizeY = 0.2325395,
							text = "无",
							color = "FFFFC045",
							fontSize = 22,
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
					name = "anjh",
					varName = "exchangeBtn",
					posX = 0.8157289,
					posY = 0.08086261,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1455703,
					sizeY = 0.1070776,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "jh",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8663929,
						sizeY = 0.8168455,
						text = "碎片交换",
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
					etype = "RichText",
					name = "cd",
					varName = "cdTime",
					posX = 0.6386798,
					posY = 0.08033048,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2163931,
					sizeY = 0.102622,
					text = "交换资讯：00：00：00",
					color = "FFFFC045",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lhbj2",
					posX = 0.3032835,
					posY = 0.2512693,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3659114,
					sizeY = 0.4940172,
					image = "guidaoyuling1#spdb",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "rewardList",
						posX = 0.499985,
						posY = 0.5470417,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9784669,
						sizeY = 0.40418,
						horizontal = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "anlh",
					varName = "getLianHuaBtn",
					posX = 0.304982,
					posY = 0.0756519,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1527093,
					sizeY = 0.1083528,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "lh1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8663929,
						sizeY = 0.8168455,
						text = "炼化",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "cs",
					varName = "lianHuaTimes",
					posX = 0.3042617,
					posY = 0.1573707,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2242625,
					sizeY = 0.07211812,
					text = "可炼次数:1000",
					color = "FFDD9A5F",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "sm",
					varName = "lianHuaTitle",
					posX = 0.3032731,
					posY = 0.4482608,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3540847,
					sizeY = 0.05509754,
					text = "说明",
					color = "FFD7372B",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "th1",
					varName = "tipBtn",
					posX = 0.4359535,
					posY = 0.156198,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03349753,
					sizeY = 0.05517241,
					image = "guiying#th",
					imageNormal = "guiying#th",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "sm2",
					varName = "lianHuaDesc",
					posX = 0.3032731,
					posY = 0.4051584,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3540847,
					sizeY = 0.05509754,
					text = "说明",
					color = "FFD7372B",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8433468,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2242187,
				sizeY = 0.2111111,
				image = "guidaoyuling1#yuling",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh9",
				varName = "yuanLingBtn",
				posX = 0.8796957,
				posY = 0.5258847,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0671875,
				sizeY = 0.1375,
				image = "guidaoyuling1#dl2",
				imageNormal = "guidaoyuling1#dl2",
				imagePressed = "guidaoyuling1#dl1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dsa",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4264869,
					sizeY = 0.8094339,
					text = "元灵",
					color = "FFE3BC8D",
					fontSize = 26,
					fontOutlineEnable = true,
					fontOutlineColor = "FF653919",
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
				varName = "lianHuaBtn",
				posX = 0.8796957,
				posY = 0.3854155,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0671875,
				sizeY = 0.1375,
				image = "guidaoyuling1#dl2",
				imageNormal = "guidaoyuling1#dl2",
				imagePressed = "guidaoyuling1#dl1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "dsa2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4264869,
					sizeY = 0.8094339,
					text = "炼化",
					color = "FFE3BC8D",
					fontSize = 26,
					fontOutlineEnable = true,
					fontOutlineColor = "FF653919",
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
				name = "dl",
				posX = 0.8792142,
				posY = 0.6691316,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0671875,
				sizeY = 0.1375,
				image = "guidaoyuling1#dl1",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5930232,
					sizeY = 0.4545455,
					image = "guidaoyuling1#gb",
					imageNormal = "guidaoyuling1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "wh",
				varName = "helpBtn",
				posX = 0.8195459,
				posY = 0.2239987,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.034375,
				sizeY = 0.06111111,
				image = "guidaoyuling1#wh",
				imageNormal = "guidaoyuling1#wh",
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	kuang = {
		kuang = {
			alpha = {{0, {0.5}}, {500, {1}}, {1000, {0.5}}, },
		},
	},
	l = {
		l = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l2 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	l2 = {
		l3 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l4 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	kuang2 = {
		kuang2 = {
			alpha = {{0, {0.5}}, {500, {1}}, {1000, {0.5}}, },
		},
	},
	l3 = {
		l5 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l6 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	l4 = {
		l7 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l8 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
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
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
	},
	gy55 = {
	},
	gy56 = {
	},
	gy57 = {
	},
	gy58 = {
	},
	gy59 = {
	},
	gy60 = {
	},
	gy61 = {
	},
	gy62 = {
	},
	gy63 = {
	},
	gy64 = {
	},
	gy65 = {
	},
	gy66 = {
	},
	gy67 = {
	},
	gy68 = {
	},
	gy69 = {
	},
	gy70 = {
	},
	gy71 = {
	},
	gy72 = {
	},
	gy73 = {
	},
	gy74 = {
	},
	gy75 = {
	},
	gy76 = {
	},
	gy77 = {
	},
	gy78 = {
	},
	gy79 = {
	},
	gy80 = {
	},
	gy81 = {
	},
	gy82 = {
	},
	gy83 = {
	},
	gy84 = {
	},
	gy85 = {
	},
	gy86 = {
	},
	gy87 = {
	},
	gy88 = {
	},
	gy89 = {
	},
	gy90 = {
	},
	gy91 = {
	},
	gy92 = {
	},
	gy93 = {
	},
	gy94 = {
	},
	gy95 = {
	},
	gy96 = {
	},
	gy97 = {
	},
	gy98 = {
	},
	gy99 = {
	},
	gy100 = {
	},
	gy101 = {
	},
	gy102 = {
	},
	gy103 = {
	},
	gy104 = {
	},
	gy105 = {
	},
	gy106 = {
	},
	gy107 = {
	},
	gy108 = {
	},
	gy109 = {
	},
	gy110 = {
	},
	gy111 = {
	},
	gy112 = {
	},
	gy113 = {
	},
	gy114 = {
	},
	gy115 = {
	},
	gy116 = {
	},
	gy117 = {
	},
	gy118 = {
	},
	gy119 = {
	},
	gy120 = {
	},
	gy121 = {
	},
	gy122 = {
	},
	gy123 = {
	},
	gy124 = {
	},
	gy125 = {
	},
	gy126 = {
	},
	gy127 = {
	},
	gy128 = {
	},
	gy129 = {
	},
	gy130 = {
	},
	gy131 = {
	},
	gy132 = {
	},
	gy133 = {
	},
	gy134 = {
	},
	gy135 = {
	},
	gy136 = {
	},
	gy137 = {
	},
	gy138 = {
	},
	gy139 = {
	},
	gy140 = {
	},
	gy141 = {
	},
	gy142 = {
	},
	gy143 = {
	},
	gy144 = {
	},
	gy145 = {
	},
	gy146 = {
	},
	gy147 = {
	},
	gy148 = {
	},
	gy149 = {
	},
	gy150 = {
	},
	gy151 = {
	},
	gy152 = {
	},
	gy153 = {
	},
	gy154 = {
	},
	gy155 = {
	},
	gy156 = {
	},
	gy157 = {
	},
	gy158 = {
	},
	gy159 = {
	},
	gy160 = {
	},
	gy161 = {
	},
	gy162 = {
	},
	gy163 = {
	},
	gy164 = {
	},
	gy165 = {
	},
	gy166 = {
	},
	gy167 = {
	},
	gy168 = {
	},
	gy169 = {
	},
	gy170 = {
	},
	gy171 = {
	},
	gy172 = {
	},
	gy173 = {
	},
	gy174 = {
	},
	gy175 = {
	},
	gy176 = {
	},
	gy177 = {
	},
	gy178 = {
	},
	gy179 = {
	},
	gy180 = {
	},
	gy181 = {
	},
	gy182 = {
	},
	gy183 = {
	},
	gy184 = {
	},
	gy185 = {
	},
	gy186 = {
	},
	gy187 = {
	},
	gy188 = {
	},
	gy189 = {
	},
	gy190 = {
	},
	gy191 = {
	},
	gy192 = {
	},
	gy193 = {
	},
	gy194 = {
	},
	gy195 = {
	},
	gy196 = {
	},
	gy197 = {
	},
	gy198 = {
	},
	gy199 = {
	},
	gy200 = {
	},
	gy201 = {
	},
	gy202 = {
	},
	gy203 = {
	},
	gy204 = {
	},
	gy205 = {
	},
	gy206 = {
	},
	gy207 = {
	},
	gy208 = {
	},
	gy209 = {
	},
	gy210 = {
	},
	gy211 = {
	},
	gy212 = {
	},
	gy213 = {
	},
	gy214 = {
	},
	gy215 = {
	},
	gy216 = {
	},
	gy217 = {
	},
	gy218 = {
	},
	gy219 = {
	},
	gy220 = {
	},
	gy221 = {
	},
	gy222 = {
	},
	gy223 = {
	},
	gy224 = {
	},
	gy225 = {
	},
	gy226 = {
	},
	gy227 = {
	},
	gy228 = {
	},
	gy229 = {
	},
	gy230 = {
	},
	gy231 = {
	},
	gy232 = {
	},
	gy233 = {
	},
	gy234 = {
	},
	gy235 = {
	},
	gy236 = {
	},
	gy237 = {
	},
	gy238 = {
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_kuang = {
		{0,"kuang", -1, 0},
		{2,"lizi", 1, 0},
		{2,"lizi2", 1, 0},
		{2,"lizi3", 1, 0},
		{2,"lizi4", 1, 0},
		{0,"l", -1, 0},
		{0,"l2", -1, 500},
	},
	c_kuang2 = {
		{2,"lizi5", 1, 0},
		{2,"lizi6", 1, 0},
		{2,"lizi7", 1, 0},
		{2,"lizi8", 1, 0},
		{0,"kuang2", -1, 0},
		{0,"l3", -1, 0},
		{0,"l4", -1, 500},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
