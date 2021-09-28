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
			etype = "Grid",
			name = "renwu",
			varName = "taskRoot",
			posX = 0.09440771,
			posY = 0.5965136,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.180874,
			sizeY = 0.259625,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "smd",
				varName = "scrollRoot",
				posX = 0.5,
				posY = 0.648985,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.030774,
				image = "b#rwd",
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
					varName = "bossScroll",
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
				name = "djk",
				varName = "sectRoot",
				posX = 1.098193,
				posY = 0.5475345,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9770589,
				sizeY = 1.223098,
				image = "b#bp",
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
					name = "djk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#bp",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lie",
					varName = "rankScorll",
					posX = 0.5000001,
					posY = 0.5941483,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.985367,
					sizeY = 0.8040274,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_rank",
					posX = 0.9590058,
					posY = 0.9584971,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2298775,
					sizeY = 0.1705785,
					image = "sdymj#x",
					imageNormal = "sdymj#x",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tswb",
					varName = "mySectScore",
					posX = 0.4874571,
					posY = 0.08952902,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9368192,
					sizeY = 0.25,
					text = "我的帮派：500",
					color = "FFFFFF80",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xun",
					varName = "goto_btn",
					posX = 0.906045,
					posY = 0.08952902,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1989325,
					sizeY = 0.205569,
					image = "sdymj#xun",
					imageNormal = "sdymj#xun",
					disablePressScale = true,
				},
			},
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ss",
			posX = 0.5,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tip",
				varName = "battleEntrance",
				posX = 0.4150329,
				posY = 0.2756727,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5125,
				sizeY = 0.1230159,
				image = "d#tst",
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "fwb",
					varName = "battleKeys",
					posX = 0.4802337,
					posY = 0.500001,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4232717,
					sizeY = 0.7294813,
					text = "幽冥密令：5/5",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb",
					posX = 0.7388434,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4324029,
					sizeY = 1.244775,
					text = "对战区",
					color = "FFFF0000",
					fontUnderlineEnable = true,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "battleZone",
					posX = 0.6010607,
					posY = 0.5175902,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1872874,
					sizeY = 0.6656619,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djt",
					posX = 0.2169349,
					posY = 0.5161058,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.07892822,
					sizeY = 0.8351116,
					image = "djk#kzi",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "mitub",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8510638,
						sizeY = 0.8510636,
						image = "items5#youmingmiling",
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
			name = "sh",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "ks",
				posX = 0.5,
				posY = 0.6247783,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3796875,
				sizeY = 0.7416667,
				image = "sdymj#nuan",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tst1",
				posX = 0.4992199,
				posY = 0.4781486,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5125,
				sizeY = 0.1722222,
				image = "d#tst",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ma",
				varName = "anisText",
				posX = 0.4992199,
				posY = 0.4781486,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				color = "FFFFF554",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "sh2",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "ks2",
				posX = 0.5210522,
				posY = 0.6360425,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3539063,
				sizeY = 0.9,
				image = "sdymj#js",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tst2",
				posX = 0.4992199,
				posY = 0.4781486,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5125,
				sizeY = 0.1722222,
				image = "d#tst",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ma2",
				varName = "anisText2",
				posX = 0.4992199,
				posY = 0.4781486,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				color = "FFFFF554",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
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
	ss = {
		ks = {
			alpha = {{0, {1}}, {1400, {1}}, {1550, {0}}, },
			scale = {{0, {5, 5, 1}}, {150, {0.9, 0.9, 1}}, {200, {1,1,1}}, },
		},
	},
	ks = {
		ks2 = {
			alpha = {{0, {1}}, {1400, {1}}, {1550, {0}}, },
			scale = {{0, {5, 5, 1}}, {150, {0.9, 0.9, 1}}, {200, {1,1,1}}, },
		},
	},
	ma = {
		ma = {
			alpha = {{0, {1}}, {1700, {1}}, {2000, {0}}, },
		},
		tst1 = {
			alpha = {{0, {1}}, {1700, {1}}, {2000, {0}}, },
		},
	},
	ma2 = {
		ma2 = {
			alpha = {{0, {1}}, {1700, {1}}, {2000, {0}}, },
		},
		tst2 = {
			alpha = {{0, {1}}, {1700, {1}}, {2000, {0}}, },
		},
	},
	c_ss = {
		{0,"ss", 1, 0},
		{0,"ma", 1, 0},
	},
	c_js = {
		{0,"ma2", 1, 0},
		{0,"ks", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
