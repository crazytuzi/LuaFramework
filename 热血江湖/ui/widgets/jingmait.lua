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
			sizeX = 0.1411731,
			sizeY = 0.09722222,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "item_bg",
				posX = 0.2071787,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3873791,
				sizeY = 1,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "item_icon",
					posX = 0.4999901,
					posY = 0.5226914,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7714558,
					sizeY = 0.7714563,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bj1",
					varName = "btn",
					posX = 0.5,
					posY = 0.3569169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.286166,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "num",
					posX = 2.002906,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.871878,
					sizeY = 0.6578311,
					text = "x16",
					color = "FF966856",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "duo",
					varName = "lock",
					posX = 0.181314,
					posY = 0.2132565,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2978723,
					sizeY = 0.2978723,
					image = "tb#suo",
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
