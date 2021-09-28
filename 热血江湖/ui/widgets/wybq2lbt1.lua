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
			name = "hdlbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1666106,
			sizeY = 0.09579011,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.022219,
				sizeY = 0.9859519,
				image = "wybq2#yq1",
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "wybq2#yq1",
				imagePressed = "wybq2#yq2",
				imageDisable = "wybq2#yq1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z",
				varName = "name",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7435679,
				sizeY = 0.8042339,
				text = "战力排行",
				color = "FF914A15",
				fontSize = 24,
				fontOutlineEnable = true,
				fontOutlineColor = "FFFFEFC8",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "jiantou",
				posX = 0.4900583,
				posY = 0.5050042,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9716445,
				sizeY = 0.9684175,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
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
