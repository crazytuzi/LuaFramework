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
			sizeX = 0.078125,
			sizeY = 0.1319444,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj5",
				varName = "root",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.95,
				sizeY = 0.9789477,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t5",
					varName = "icon",
					posX = 0.4894885,
					posY = 0.5212737,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "items#items_lanselihe.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl5",
					varName = "count",
					posX = 0.5295953,
					posY = 0.1949284,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7505371,
					sizeY = 0.3380342,
					text = "x12",
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo5",
					varName = "lock",
					posX = 0.176784,
					posY = 0.2166903,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3157896,
					sizeY = 0.3125001,
					image = "tb#tb_suo.png",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "btn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
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
