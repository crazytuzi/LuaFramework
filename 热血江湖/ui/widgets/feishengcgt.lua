--version = 1
local l_fileType = "node"

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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1856326,
			sizeY = 0.04861111,
			alpha = 0,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zt",
				varName = "icon",
				posX = 0.09659972,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1683432,
				sizeY = 1.142857,
				image = "zt#qixue",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sx1",
				varName = "name",
				posX = 0.4915829,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 1.807963,
				text = "属性1",
				color = "FFFFFE9E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				posX = 0.5841711,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05892015,
				sizeY = 0.4285715,
				image = "chu1#jt",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sx2",
				varName = "value",
				posX = 0.9094939,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5252073,
				sizeY = 1.807963,
				text = "500",
				color = "FF8BF360",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx_1",
				posX = 0.4931649,
				posY = 0.4547509,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7575448,
				sizeY = 8.714287,
				image = "uieffect/039lizi_3.png",
				alpha = 0,
				rotation = 90,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx_2",
				posX = 0.04401003,
				posY = 0.3384603,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7575448,
				sizeY = 3.428572,
				image = "uieffect/039lizi.png",
				alpha = 0,
				rotation = 90,
				blendFunc = 1,
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
	tx_2 = {
		tx_2 = {
			move = {{0, {-10, 17.08715, 0}}, {500, {240, 17.08715, 0}}, },
			alpha = {{0, {0}}, {100, {0.4}}, {250, {0.8}}, {400, {0.2}}, {500, {0}}, {850, {0}}, },
			scale = {{0, {1, 0.4, 1}}, {250, {1,1,1}}, {500, {1, 0.1, 1}}, },
		},
		tx_1 = {
			alpha = {{0, {0}}, {50, {0}}, {250, {0.7}}, {350, {0.7}}, {550, {0}}, {850, {0}}, },
		},
	},
	c_dakai = {
		{0,"tx_2", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
