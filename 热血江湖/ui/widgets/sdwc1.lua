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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5,
			sizeY = 0.08,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "bg",
				posX = 0.4947968,
				posY = 0.4999983,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.85,
				sizeY = 0.8506945,
				image = "cl2#dw3",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz1",
				varName = "textLable",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.8319729,
				text = "第一次",
				color = "FFFFFF00",
				fontSize = 24,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
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
