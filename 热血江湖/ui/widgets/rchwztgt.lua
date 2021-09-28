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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.06875,
			sizeY = 0.1225002,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "icon_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "item_icon",
					posX = 0.5031568,
					posY = 0.5115648,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8332064,
					sizeY = 0.8381271,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btns",
					varName = "bt",
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
					name = "suo",
					varName = "suo",
					posX = 0.1709948,
					posY = 0.2056765,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3181818,
					sizeY = 0.3174598,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "item_count",
					posX = 0.5939316,
					posY = 0.183268,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6516899,
					sizeY = 0.6117363,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
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
