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
		closeAfterOpenAni = true,
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "aaa",
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
				name = "ddd",
				varName = "closeBtn",
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
			alpha = 0,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tu_6",
				posX = 0.4970231,
				posY = 0.6082582,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7453617,
				sizeY = 0.5576244,
				image = "uieffect/guang2.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tu_2",
				posX = 0.5054567,
				posY = 0.6449005,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4867011,
				sizeY = 0.470062,
				image = "uieffect/juxing.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jht",
				posX = 0.5,
				posY = 0.59835,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3429688,
				sizeY = 0.2833333,
				image = "jiebai#jbcg",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "des",
				posX = 0.5,
				posY = 0.5721976,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4068547,
				sizeY = 0.1360939,
				color = "FF6D2C12",
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tu_1",
				posX = 0.4963066,
				posY = 0.6923762,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3825955,
				sizeY = 0.4679434,
				image = "uieffect/jpg_ly_waikuozhu01.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tu_4",
				posX = 0.3777515,
				posY = 0.596004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3825955,
				sizeY = 0.1,
				image = "uieffect/flare0422.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tu_5",
				posX = 0.6304603,
				posY = 0.5516316,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3825955,
				sizeY = 0.1,
				image = "uieffect/flare0422.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tu_3",
				posX = 0.6160831,
				posY = 0.700609,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1638691,
				sizeY = 0.2302689,
				image = "uieffect/flare042.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "FrameAni",
				name = "tu_7",
				sizeXAB = 399.9702,
				sizeYAB = 127.7889,
				posXAB = 629.702,
				posYAB = 457.8396,
				posX = 0.4919547,
				posY = 0.6358883,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3124767,
				sizeY = 0.1774846,
				frameEnd = 16,
				frameName = "uieffect/xl_003.png",
				delay = 0.05,
				playTimes = 1,
				frameWidth = 64,
				frameHeight = 64,
				column = 4,
				blendFunc = 1,
				playOnInit = false,
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
		fwb = {
			alpha = {{0, {0}}, {600, {1}}, {2000, {1}}, {2400, {0}}, },
		},
	},
	tu_3 = {
		tu_3 = {
			alpha = {{0, {0}}, {600, {1}}, {2500, {0}}, },
			rotate = {{0, {0}}, {1250, {45}}, {2500, {90}}, },
		},
	},
	tu_1 = {
		tu_1 = {
			alpha = {{0, {0}}, {100, {0.7}}, {500, {0.6}}, {2500, {0}}, },
		},
	},
	tu_2 = {
		tu_2 = {
			alpha = {{0, {0}}, {400, {0.8}}, {1800, {1}}, {2400, {0}}, },
			scale = {{0, {1,1,1}}, {300, {2, 1, 1}}, },
		},
		jht = {
			alpha = {{0, {1}}, {2000, {1}}, {2400, {0}}, },
		},
	},
	tu_4 = {
		tu_4 = {
			move = {{0, {483.5219,429.1229,0}}, {1000, {700, 429.1229, 0}}, {1400, {800, 429.1229, 0}}, },
			alpha = {{0, {0}}, {300, {1}}, {1200, {1}}, {1600, {0}}, },
			scale = {{0, {1, 2, 1}}, {1200, {1.2, 0.6, 1}}, },
		},
	},
	tu_5 = {
		tu_5 = {
			alpha = {{0, {0}}, {300, {1}}, {1200, {1}}, {1600, {0}}, },
			scale = {{0, {1, 2, 1}}, {1200, {1.2, 0.6, 1}}, },
			move = {{0, {806.9892,397.1748,0}}, {1000, {580, 397.1748, 0}}, {1400, {480, 397.1748, 0}}, },
		},
	},
	tu_6 = {
		tu_6 = {
			scale = {{0, {5, 5, 1}}, {200, {0.9, 0.9, 1}}, {300, {1,1,1}}, },
			alpha = {{0, {0.6}}, {2000, {0.6}}, {2400, {0}}, },
		},
	},
	c_dakai = {
		{0,"tu_2", 1, 50},
		{0,"tu_4", 1, 0},
		{0,"tu_5", 1, 0},
		{0,"tu_6", 1, 0},
		{0,"tu_1", 1, 50},
		{1,"tu_7", 1, 50},
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
