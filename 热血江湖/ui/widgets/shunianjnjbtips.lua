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
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2218803,
			sizeY = 0.04861111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djk",
				posX = 0.09858913,
				posY = 0.4773118,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1551928,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "buff",
					varName = "icon",
					posX = 0.4993889,
					posY = 0.5163771,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7940864,
					sizeY = 1,
					image = "items5#fuwenjinghua",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "des",
				posX = 0.5573878,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7288595,
				sizeY = 1,
				text = "道具描述xxxxxxx",
				color = "FFE9B86D",
				fontSize = 16,
				vTextAlign = 1,
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
