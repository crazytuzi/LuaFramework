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
			sizeX = 0.3554688,
			sizeY = 0.07907774,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "sxz",
				varName = "desc",
				posX = 0.5274017,
				posY = 0.4824364,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.958814,
				sizeY = 0.8632898,
				text = "什么什么套装可变色",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
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
