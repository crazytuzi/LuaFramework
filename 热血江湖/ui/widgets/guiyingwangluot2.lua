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
			name = "jds",
			posX = 0.4360431,
			posY = 0.444218,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1442919,
			sizeY = 0.3460198,
		},
		children = {
		{
			prop = {
				etype = "Sprite3D",
				name = "mx10",
				varName = "model",
				posX = 0.4999998,
				posY = -0.6612046,
				anchorX = 0.5,
				anchorY = 0,
				sizeX = 0.834941,
				sizeY = 1.530794,
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
