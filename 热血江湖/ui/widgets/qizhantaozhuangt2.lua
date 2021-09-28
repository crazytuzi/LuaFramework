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
			sizeX = 0.196875,
			sizeY = 0.05,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "sx",
				varName = "desc",
				posX = 0.4773435,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.513208,
				sizeY = 1.527778,
				text = "物理攻击:null",
				color = "FF966856",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sz",
				varName = "value",
				posX = 0.9460533,
				posY = 0.4999999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6874812,
				sizeY = 1.527778,
				text = "34567890",
				color = "FFF1E9D7",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "max",
				varName = "propertyIcon",
				posX = 0.1150794,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1571429,
				sizeY = 1.1,
				image = "zt#qixue",
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
