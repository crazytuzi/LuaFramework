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
			etype = "Image",
			name = "jieshao",
			varName = "descRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2882813,
			sizeY = 0.8388889,
			scale9 = true,
			scale9Left = 0.3,
			scale9Right = 0.3,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "js",
				varName = "desc",
				posX = 0.5130688,
				posY = 0.5165449,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8215859,
				sizeY = 0.6908672,
				text = "武林之宝之一，武林之宝之一，武林之宝之一，武林之宝之一，武林之宝之一，武林之宝之一，",
				color = "FF966856",
				fontSize = 24,
				lineSpace = 4,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
