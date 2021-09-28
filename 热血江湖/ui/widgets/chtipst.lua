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
			sizeX = 0.2554688,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "sx",
				varName = "desc",
				posX = 0.4295929,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4025645,
				sizeY = 0.8632898,
				text = "物理攻击:null",
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sz",
				varName = "value",
				posX = 0.7437052,
				posY = 0.4999999,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4025645,
				sizeY = 0.8632898,
				text = "34567890",
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sxt",
				posX = 0.1183657,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1498471,
				sizeY = 0.9799999,
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
