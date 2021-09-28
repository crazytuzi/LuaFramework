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
			sizeX = 0.09375,
			sizeY = 0.1902778,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "wb1",
				varName = "desc",
				posX = 0.5,
				posY = 0.6970804,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9644699,
				sizeY = 0.6289492,
				text = "助攻积分",
				color = "FF7A3A3A",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb2",
				varName = "value",
				posX = 0.5,
				posY = 0.2664224,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.314504,
				sizeY = 0.7965567,
				text = "55",
				color = "FF9C614E",
				fontSize = 22,
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
