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
			sizeX = 0.2515625,
			sizeY = 0.1388889,
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
				sizeX = 0.8291926,
				sizeY = 0.9899999,
				image = "jjc#jjd2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "jjc#jjd2",
				imagePressed = "jjc#jjd3",
				imageDisable = "jjc#jjd2",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t",
				varName = "icon",
				posX = 0.6406817,
				posY = 0.51,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5217391,
				sizeY = 0.8799999,
				image = "jjc2#sl",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z",
				varName = "name",
				posX = 0.5616491,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6513256,
				sizeY = 0.8042339,
				text = "战力排行",
				color = "FF914A15",
				fontSize = 24,
				fontOutlineEnable = true,
				fontOutlineColor = "FFFFEFC8",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jx",
				varName = "redPoint",
				posX = 0.2017152,
				posY = 0.8145289,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2919255,
				sizeY = 0.52,
				image = "qyrw#jx",
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
