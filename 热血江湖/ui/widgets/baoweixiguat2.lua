--version = 1
local l_fileType = "node"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "root",
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
			sizeX = 0.125,
			sizeY = 0.2777778,
		},
		children = {
		{
			prop = {
				etype = "Sprite3D",
				name = "mxs",
				varName = "obstacle",
				posX = 0.4937567,
				posY = 0.4775339,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4742215,
				sizeY = 0.5041741,
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
