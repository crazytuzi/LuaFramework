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
			sizeX = 0.2078125,
			sizeY = 0.04861111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "t2",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "dati#pht",
				scale9 = true,
				scale9Left = 0.33,
				scale9Right = 0.33,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "roleId",
				posX = 0.1123338,
				posY = 0.5377358,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2130232,
				sizeY = 0.8191623,
				text = "1",
				color = "FF966856",
				fontOutlineColor = "FF00152E",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "roleName",
				posX = 0.5155479,
				posY = 0.5377359,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6294262,
				sizeY = 0.8191623,
				text = "名字七啊啊",
				color = "FF966856",
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz3",
				varName = "bonus",
				posX = 0.9319615,
				posY = 0.5377359,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2470227,
				sizeY = 0.8191623,
				text = "5555",
				color = "FF966856",
				fontOutlineColor = "FF00152E",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "d1",
				varName = "image",
				posX = 0.102166,
				posY = 0.5759839,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1466165,
				sizeY = 0.7714286,
				image = "dati#1st",
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
