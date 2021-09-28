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
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4705256,
				sizeY = 0.567196,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.1,
				scale9Bottom = 0.1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.0219,
					sizeY = 1.097384,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jqd",
					posX = 0.5,
					posY = 0.8398435,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9431697,
					sizeY = 0.2640953,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jqd2",
					posX = 0.5,
					posY = 0.4970259,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9431697,
					sizeY = 0.2640953,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl2",
					varName = "power_label",
					posX = 0.2309121,
					posY = 0.8781618,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4163973,
					sizeY = 0.178784,
					text = "炼金术！",
					color = "FFFFF554",
					fontSize = 26,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl7",
					varName = "times_desc",
					posX = 0.4933701,
					posY = 0.3194009,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7712854,
					sizeY = 0.178784,
					text = "本日剩余提取次数：5",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF06100F",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl8",
					varName = "desc",
					posX = 0.526706,
					posY = 0.05771388,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7422605,
					sizeY = 0.178784,
					text = "若您的历练充裕，可以将自己的历练提取获得一个【历练瓶（满）】（可以到寄售行售卖）\n",
					color = "FFC93034",
					fontOutlineColor = "FF06100F",
					hTextAlign = 1,
					vTextAlign = 1,
					colorTL = "FFFFFE85",
					colorTR = "FFFFFE85",
					colorBR = "FFFFA628",
					colorBL = "FFFFA628",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.5016598,
					posY = 0.6692315,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.02324528,
					sizeY = 0.03673039,
					image = "chu1#jt",
					flippedY = true,
					rotation = 90,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "saveBtn",
					posX = 0.5,
					posY = 0.1956794,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2889057,
					sizeY = 0.1616137,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8401152,
						sizeY = 1.00501,
						text = "提 取",
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
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1.05057,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4383396,
					sizeY = 0.127332,
					image = "chu1#top",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tt",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5151515,
						sizeY = 0.4807693,
						image = "biaoti#lltq",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd1",
					posX = 0.2670985,
					posY = 0.8413275,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4525025,
					sizeY = 0.2863505,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj1",
						varName = "nullIronBg",
						posX = 0.2106006,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3485855,
						sizeY = 0.7952787,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "jft1",
							varName = "nullIron",
							posX = 0.5,
							posY = 0.5215054,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb1",
						varName = "nullName",
						posX = 0.7264476,
						posY = 0.7094992,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6058856,
						sizeY = 0.4287397,
						text = "道具名字1",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb2",
						varName = "nullLab",
						posX = 0.7264476,
						posY = 0.3417912,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6058856,
						sizeY = 0.4287397,
						text = "道具名字1",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "bt1",
						varName = "bt1",
						posX = 0.2923031,
						posY = 0.5130861,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5216299,
						sizeY = 0.7873117,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd2",
					posX = 0.76,
					posY = 0.8413275,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4525025,
					sizeY = 0.2863505,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj2",
						varName = "needCoinIronBg",
						posX = 0.2106006,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3485855,
						sizeY = 0.7952787,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "jft2",
							varName = "needCoinIron",
							posX = 0.5,
							posY = 0.5215054,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb3",
						varName = "needCoinName",
						posX = 0.7264476,
						posY = 0.7094992,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6058856,
						sizeY = 0.4287397,
						text = "道具名字1",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb4",
						varName = "needCoinLab",
						posX = 0.7264476,
						posY = 0.3417912,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6058856,
						sizeY = 0.4287397,
						text = "道具名字1",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "bt2",
						varName = "bt2",
						posX = 0.2923031,
						posY = 0.5130861,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5216299,
						sizeY = 0.7873117,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd3",
					posX = 0.5,
					posY = 0.4902052,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4525025,
					sizeY = 0.2863505,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj3",
						varName = "bg3",
						posX = 0.2106006,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3485855,
						sizeY = 0.7952787,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "jft3",
							varName = "icon3",
							posX = 0.5,
							posY = 0.5215054,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb5",
						varName = "name3",
						posX = 0.7264476,
						posY = 0.7094992,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6058856,
						sizeY = 0.4287397,
						text = "道具名字1",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb6",
						varName = "count3",
						posX = 0.7264476,
						posY = 0.3417912,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6058856,
						sizeY = 0.4287397,
						text = "道具名字1",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "bt3",
						varName = "bt3",
						posX = 0.2923031,
						posY = 0.5130861,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5216299,
						sizeY = 0.7873117,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.7260249,
				posY = 0.7651453,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	guang = {
		guang = {
			alpha = {{0, {1}}, {200, {0}}, },
			scale = {{0, {1,1,1}}, {100, {2, 2, 1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_jinbi = {
		{0,"guang", 1, 0},
		{2,"lizi", 1, 50},
		{2,"lizi2", 1, 50},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
