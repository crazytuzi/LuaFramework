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
			etype = "Image",
			name = "dj2",
			varName = "item_bg",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0734375,
			sizeY = 0.1305556,
			image = "djk#ktong",
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "add_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djt2",
				varName = "item_icon",
				posX = 0.4976079,
				posY = 0.5095236,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7651346,
				sizeY = 0.7620038,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo2",
				posX = 0.1706604,
				posY = 0.2132419,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2978723,
				sizeY = 0.2978723,
				image = "tb#suo",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl2",
				varName = "item_count",
				posX = 0.5667338,
				posY = 0.2013503,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6907982,
				sizeY = 0.3371701,
				text = "x6",
				fontSize = 18,
				fontOutlineEnable = true,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hui",
				varName = "gray_icon",
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
				etype = "Button",
				name = "jian",
				varName = "reduce_btn",
				posX = 0.8188911,
				posY = 0.8242058,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4676799,
				sizeY = 0.4570761,
				propagateToChildren = true,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "nb",
					posX = 0.4459085,
					posY = 0.4729547,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5914211,
					sizeY = 0.6051413,
					image = "smd#jian",
					imageNormal = "smd#jian",
					disablePressScale = true,
					disableClick = true,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
