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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cjsl",
				varName = "img",
				posX = 0.4888639,
				posY = 0.4928946,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.03439,
				sizeY = 1.063492,
				image = "xfph#xfph",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sj1",
				posX = 0.5823897,
				posY = 0.6813432,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3366921,
				sizeY = 0.1680121,
				text = "活动期限：",
				color = "FFFFFCCB",
				fontSize = 22,
				fontOutlineColor = "FFFDE2FF",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sj2",
				varName = "ActivitiesTime",
				posX = 0.8208123,
				posY = 0.6813432,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4987522,
				sizeY = 0.1680121,
				text = "2017~2015",
				color = "FFFFFCCB",
				fontSize = 22,
				fontOutlineColor = "FFFDE2FF",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "ck",
				varName = "consume_rank_btn",
				posX = 0.6865255,
				posY = 0.1174109,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3522205,
				sizeY = 0.1723356,
				image = "phb2#an",
				imageNormal = "phb2#an",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "ms",
				varName = "ActivitiesContent",
				posX = 0.6857576,
				posY = 0.471702,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5244049,
				sizeY = 0.2467595,
				text = "描述文字变色",
				color = "FFE82E18",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
