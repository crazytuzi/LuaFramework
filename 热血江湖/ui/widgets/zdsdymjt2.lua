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
			varName = "node",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1734375,
			sizeY = 0.05,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "sxz",
				varName = "sectName",
				posX = 0.5144549,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9710901,
				sizeY = 1,
				text = "1.我的帮派七个字",
				color = "FFFFFFC0",
				fontSize = 18,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb",
				varName = "score",
				posX = 0.9741561,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5071581,
				sizeY = 1,
				text = "6000",
				color = "FFFFFFC0",
				fontSize = 18,
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
