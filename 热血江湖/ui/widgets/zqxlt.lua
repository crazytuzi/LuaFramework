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
			name = "djj",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.15625,
			sizeY = 0.1013889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dao3",
				varName = "itemBorder",
				posX = 0.2240504,
				posY = 0.4789474,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3728493,
				sizeY = 1,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "daot3",
					varName = "itemImg",
					posX = 0.4931769,
					posY = 0.5242159,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8208835,
					sizeY = 0.8158697,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "daoan3",
					varName = "itemBtn",
					posX = 0.9289657,
					posY = 0.5179855,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.679782,
					sizeY = 0.8940133,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "daos3",
					varName = "itemNum",
					posX = 2.314068,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.54502,
					sizeY = 0.961989,
					text = "0/2",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lockImg",
					posX = 0.2055196,
					posY = 0.2400894,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3352561,
					sizeY = 0.3424657,
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
