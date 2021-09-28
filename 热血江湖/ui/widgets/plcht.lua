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
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.075,
			sizeY = 0.1347222,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "bt",
				posX = 0.499992,
				posY = 0.5259969,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9012964,
				sizeY = 0.8839707,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "grade_icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9895833,
				sizeY = 0.9896909,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t",
					varName = "item_icon",
					posX = 0.4999925,
					posY = 0.5138316,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "tiems#items_zhongjijinengshu.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.2056757,
					posY = 0.2295872,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2947368,
					sizeY = 0.2916667,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "item_count",
					posX = 0.5811765,
					posY = 0.2036264,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6572966,
					sizeY = 0.3433895,
					text = "x88",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yx",
				posX = 0.4971809,
				posY = 0.5207896,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.9207726,
				sizeY = 0.9473031,
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
					name = "dj",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4298926,
					sizeY = 0.3700141,
					image = "chu1#dj",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
