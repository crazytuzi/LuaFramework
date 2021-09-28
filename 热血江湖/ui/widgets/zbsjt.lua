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
			sizeX = 0.3484375,
			sizeY = 0.06388889,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "wz",
				varName = "text",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 0.9641256,
				sizeY = 0.8851417,
				text = "装备升级",
				color = "FF966856",
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
