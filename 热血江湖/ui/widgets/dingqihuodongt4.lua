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
			posX = 0.4996096,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9975793,
			sizeY = 0.0473507,
			vTextAlign = 1,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "ssss",
				varName = "txt",
				posX = 0.4987675,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.004028,
				sizeY = 1,
				text = "文本文本问呢",
				color = "FFFF0000",
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
