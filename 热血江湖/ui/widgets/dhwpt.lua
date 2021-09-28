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
			name = "lb",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0625,
			sizeY = 0.1375,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "p11",
				varName = "bg",
				posX = 0.5,
				posY = 0.605263,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1,
				sizeY = 0.8080809,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "p1111",
					varName = "icon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8096378,
					sizeY = 0.8127146,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "p112",
					varName = "lock",
					posX = 0.1986919,
					posY = 0.21017,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3191488,
					sizeY = 0.319149,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "count",
					posX = 0.5,
					posY = -0.1012179,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.344166,
					sizeY = 0.3891595,
					text = "999",
					color = "FF966856",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "btn",
					posX = 0.5,
					posY = 0.3946539,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.223062,
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
