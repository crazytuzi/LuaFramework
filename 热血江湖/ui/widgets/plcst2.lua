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
					posY = 0.5450817,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "tiems#items_zhongjijinengshu.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "item_count",
					posX = 0.4603378,
					posY = 0.1724996,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9200266,
					sizeY = 0.8009784,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.1846963,
					posY = 0.1984569,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2947368,
					sizeY = 0.2916666,
					image = "tb#suo",
				},
			},
			},
		},
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
