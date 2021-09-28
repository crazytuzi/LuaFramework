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
			sizeX = 0.2578125,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "wb",
				varName = "text",
				posX = 0.5,
				posY = 1,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 0.969697,
				sizeY = 0.9499999,
				text = "说明",
				color = "FFFFAC4B",
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
