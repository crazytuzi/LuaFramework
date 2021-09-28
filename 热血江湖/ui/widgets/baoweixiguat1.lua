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
			name = "jiedian",
			varName = "page",
			posX = 0.5007812,
			posY = 0.4183102,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.8333333,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tp",
				posX = 0.5,
				posY = 0.5999992,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.2,
				image = "bwxgbj#bwxgbj",
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "scoll",
				posX = 0.5015382,
				posY = 0.4980278,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9983994,
				sizeY = 1,
				horizontal = true,
				showScrollBar = false,
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
