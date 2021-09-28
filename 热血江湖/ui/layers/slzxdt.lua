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
			posX = 0.9180776,
			posY = 0.8835866,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.1576897,
			sizeY = 0.2263464,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "gg",
				posX = 0.5129579,
				posY = 0.5748944,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9848016,
				sizeY = 0.834537,
				image = "b#rwd",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "ScrollView",
				name = "lb3",
				varName = "mapScroll",
				posX = 0.5141315,
				posY = 0.579558,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9596992,
				sizeY = 0.8065987,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "smd",
				posX = 0.5130475,
				posY = 0.8986332,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9958244,
				sizeY = 0.1963559,
				image = "zd#wk",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "worldCoord",
				posX = 0.5165718,
				posY = 0.914516,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9414086,
				sizeY = 0.2020942,
				text = "玄渤竹林",
				color = "FF43261D",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "hxa",
				varName = "worldline_btn",
				posX = 0.5086386,
				posY = 0.8851709,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.25,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
