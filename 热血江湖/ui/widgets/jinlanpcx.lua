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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1323642,
			sizeY = 0.203947,
		},
		children = {
		{
			prop = {
				etype = "Sprite3D",
				name = "mx5",
				varName = "player",
				posX = 0.5,
				posY = -0.9616264,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.029462,
				sizeY = 1.776651,
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
