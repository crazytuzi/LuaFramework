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
			etype = "List",
			name = "lb",
			varName = "list",
			posX = 0.2571838,
			posY = 0.5063421,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3280784,
			sizeY = 0.6893512,
			horizontal = true,
		},
	},
	},
}
--EDITOR elements end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot)
end
return create
