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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "gg",
				posX = 0.8872578,
				posY = 0.8694459,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2254196,
				sizeY = 0.2563518,
				image = "b#rwd",
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
					name = "rwlb",
					varName = "rankScroll",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9676862,
					sizeY = 0.9430666,
					showScrollBar = false,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
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
	chu = {
		dyjd = {
			moveP = {{0, {-0.3, 0.5, 0}}, {300, {0.5, 0.5, 0}}, },
		},
	},
	ru = {
		dyjd = {
			moveP = {{0, {0.5, 0.5, 0}}, {200, {-0.3, 0.5, 0}}, },
		},
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
	c_dakai = {
	},
	c_dakai2 = {
	},
	c_chu = {
		{0,"chu", 1, 0},
	},
	c_ru = {
		{0,"ru", 1, 0},
	},
	c_dakai3 = {
	},
	c_dakai4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
