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
					posX = 0.4999925,
					posY = 0.5450817,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
					image = "tiems#items_zhongjijinengshu.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
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
