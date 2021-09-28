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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1528737,
			sizeY = 0.09636825,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "wb11",
				varName = "txt",
				posX = 0.5,
				posY = 0.4944927,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9965335,
				sizeY = 1.004482,
				text = "111",
				color = "FFFF9F5F",
				fontOutlineColor = "FFAA654A",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
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
