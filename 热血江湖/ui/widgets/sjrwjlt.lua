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
			posY = 0.501387,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1240138,
			sizeY = 0.1331146,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "p2",
				varName = "item_bg",
				posX = 0.2654467,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.592172,
				sizeY = 0.9807756,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "p3",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8247142,
					sizeY = 0.8247142,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "dj",
					varName = "item_btn",
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
					etype = "Label",
					name = "xz1",
					varName = "item_count",
					posX = 1.395843,
					posY = 0.4893857,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.743446,
					sizeY = 0.4885532,
					text = "x155",
					color = "FF966856",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.2703354,
					posY = 0.2769668,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3723404,
					sizeY = 0.3723404,
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
