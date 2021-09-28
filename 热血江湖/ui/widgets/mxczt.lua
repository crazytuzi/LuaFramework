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
			sizeX = 0.07955503,
			sizeY = 0.1638889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.5984849,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8641817,
				sizeY = 0.7457625,
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
		{
			prop = {
				etype = "Label",
				name = "x",
				varName = "num",
				posX = 0.5097945,
				posY = 0.1146354,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.194132,
				sizeY = 0.3968956,
				text = "x点/个",
				color = "FF966856",
				hTextAlign = 1,
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
