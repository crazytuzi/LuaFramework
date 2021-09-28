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
			sizeX = 0.1835938,
			sizeY = 0.07638889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7531913,
				sizeY = 0.9636363,
				image = "jy#sn2",
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "jy#sn2",
				imagePressed = "jy#sn1",
				imageDisable = "jy#sn2",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "nameLabel",
				posX = 0.5574396,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7285399,
				sizeY = 1.228006,
				text = "具体什么",
				color = "FF914A15",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "desc",
				posX = 0.4731881,
				posY = 0.5000005,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6366322,
				sizeY = 1.228006,
				text = "Lv1",
				color = "FF65944D",
				hTextAlign = 2,
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
