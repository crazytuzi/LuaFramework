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
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zi",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "g#g_zit.png",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hong",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "g#g_hongt.png",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "boss",
				posX = 0.4976605,
				posY = 0.6497533,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7654095,
				sizeY = 0.3189207,
				layoutType = 5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5225961,
					sizeY = 2.229743,
					image = "uieffect/BOSS-0.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bos",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3333333,
					sizeY = 1.422222,
					image = "uieffect/BOSS.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5225961,
					sizeY = 2.229743,
					image = "uieffect/BOSS-0.png",
					alpha = 0,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bos2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3333333,
					sizeY = 1.422222,
					image = "uieffect/BOSS.png",
					alpha = 0,
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
	boss = {
		bos = {
			move = {{0, {-200, 114.8115, 0}}, {150, {489.8621,114.8115,0}}, },
			alpha = {{0, {0}}, {100, {1}}, {200, {1}}, {250, {0}}, },
			scale = {{0, {1,1,1}}, {200, {1.2, 1.2, 1}}, },
		},
	},
	xian = {
		xian = {
			move = {{0, {1200, 114.8115, 0}}, {150, {489.8621,114.8115,0}}, },
			alpha = {{0, {0}}, {100, {1}}, {250, {0}}, },
			scale = {{0, {1,1,1}}, {200, {1.2, 1.2, 1}}, },
		},
	},
	boss2 = {
		bos2 = {
			scale = {{0, {1.2, 1.2, 1}}, {200, {1.5, 1.5, 1}}, {400, {1.2, 1.2, 1}}, {600, {1.5, 1.5, 1}}, {800, {1.2, 1.2, 1}}, },
			alpha = {{0, {1}}, {500, {1}}, {850, {0}}, },
		},
	},
	xian2 = {
		xian2 = {
			scale = {{0, {1.2, 1.2, 1}}, {200, {1.5, 1.5, 1}}, {400, {1.2, 1.2, 1}}, {600, {1.5, 1.5, 1}}, {800, {1.2, 1.2, 1}}, },
			alpha = {{0, {1}}, {500, {1}}, {800, {0}}, },
		},
	},
	zise = {
		zi = {
			alpha = {{0, {0}}, {700, {1}}, {1400, {0}}, },
		},
	},
	hongse = {
		hong = {
			alpha = {{0, {0}}, {250, {1}}, {500, {0}}, },
		},
	},
	gy = {
	},
	c_dakai = {
		{0,"boss", 1, 0},
		{0,"xian", 1, 0},
		{0,"boss2", 1, 200},
		{0,"xian2", 1, 200},
		{0,"hongse", 2, 200},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
