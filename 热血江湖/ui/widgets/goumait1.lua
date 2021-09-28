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
			sizeX = 0.20625,
			sizeY = 0.09722222,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dt3",
				varName = "btn",
				posX = 0.4999999,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9714287,
				image = "phb#ph1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "phb#ph1",
				imagePressed = "phb#ph2",
				imageDisable = "phb#ph1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "pickupImg",
				posX = 0.1446471,
				posY = 0.4826389,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1102941,
				sizeY = 0.3703704,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "nameLabel",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6937115,
				sizeY = 0.7982667,
				text = "物品种类",
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
				name = "dt4",
				varName = "openImg",
				posX = 0.144647,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.125,
				sizeY = 0.1358025,
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
