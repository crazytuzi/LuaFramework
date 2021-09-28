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
			name = "xunlu",
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
				name = "xun",
				posX = 0.4048276,
				posY = 0.4514702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/qian",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "lu",
				posX = 0.4448663,
				posY = 0.4514702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/wang",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zhong",
				posX = 0.484905,
				posY = 0.4514702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/an",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dd",
				posX = 0.5867378,
				posY = 0.4320436,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.025,
				sizeY = 0.04444445,
				image = "uieffect/dd.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dd2",
				posX = 0.6039258,
				posY = 0.4320436,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.025,
				sizeY = 0.04444445,
				image = "uieffect/dd.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dd3",
				posX = 0.621114,
				posY = 0.4320436,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.025,
				sizeY = 0.04444445,
				image = "uieffect/dd.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zhong2",
				posX = 0.5249437,
				posY = 0.4514702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/quan",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zhong3",
				posX = 0.5649824,
				posY = 0.4514702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.08888889,
				image = "uieffect/qu",
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
	gy = {
	},
	xun = {
		xun = {
			scale = {{0, {0, 1, 1}}, {200, {1.1, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {1}}, {2000, {1}}, {2500, {0}}, {2600, {0}}, },
		},
	},
	lu = {
		lu = {
			scale = {{0, {0, 1, 1}}, {200, {1.1, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {1}}, {1900, {1}}, {2400, {0}}, {2600, {0}}, },
		},
	},
	zhong = {
		zhong = {
			scale = {{0, {0, 1, 1}}, {200, {1.1, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {1}}, {1800, {1}}, {2300, {0}}, {2600, {0}}, },
		},
	},
	dd1 = {
		dd = {
			alpha = {{0, {1}}, {1700, {1}}, {2200, {0}}, {2600, {0}}, },
		},
	},
	dd2 = {
		dd2 = {
			alpha = {{0, {1}}, {1600, {1}}, {2100, {0}}, {2600, {0}}, },
		},
	},
	dd3 = {
		dd3 = {
			alpha = {{0, {1}}, {1500, {1}}, {2000, {0}}, {2600, {0}}, },
		},
	},
	diao = {
		zhong2 = {
			scale = {{0, {0, 1, 1}}, {200, {1.1, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {1}}, {1800, {1}}, {2300, {0}}, {2600, {0}}, },
		},
	},
	yu = {
		zhong3 = {
			scale = {{0, {0, 1, 1}}, {200, {1.1, 1, 1}}, {250, {1,1,1}}, },
			alpha = {{0, {1}}, {1800, {1}}, {2300, {0}}, {2600, {0}}, },
		},
	},
	c_xunluzhong = {
		{0,"xun", -1, 0},
		{0,"lu", -1, 100},
		{0,"zhong", -1, 200},
		{0,"dd1", -1, 300},
		{0,"dd2", -1, 400},
		{0,"dd3", -1, 500},
	},
	c_dakai = {
		{0,"xun", -1, 0},
		{0,"lu", -1, 100},
		{0,"zhong", -1, 200},
		{0,"dd1", -1, 600},
		{0,"dd2", -1, 700},
		{0,"dd3", -1, 800},
		{0,"diao", -1, 400},
		{0,"yu", -1, 500},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
