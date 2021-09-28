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
			name = "zbsct3",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3359375,
			sizeY = 0.1111111,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "tz1",
				varName = "text1",
				posX = 0.3029176,
				posY = 0.7779026,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.4605066,
				text = "限定刀系  2转",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tz2",
				varName = "text2",
				posX = 0.3029176,
				posY = 0.2916962,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.4605066,
				text = "属性条1",
				fontSize = 22,
				vTextAlign = 1,
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
