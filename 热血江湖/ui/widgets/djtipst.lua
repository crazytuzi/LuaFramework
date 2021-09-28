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
			name = "k2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2,
			sizeY = 0.12,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "sx",
				varName = "sz",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8675372,
				sizeY = 0.8632898,
				text = "两个字",
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
