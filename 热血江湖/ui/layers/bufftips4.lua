--version = 1
local l_fileType = "layer"

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
			name = "jm",
			varName = "root",
			posX = 0.3931448,
			posY = 0.7787098,
			anchorX = 0,
			anchorY = 1,
			sizeX = 0.2109375,
			sizeY = 0.2759341,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "bg",
				posX = 0.4966433,
				posY = 1,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 0.9916599,
				sizeY = 0.9887164,
				image = "b#bp",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "scroll",
				posX = 0.4975016,
				posY = 0.5025118,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9883086,
				sizeY = 0.9346715,
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
