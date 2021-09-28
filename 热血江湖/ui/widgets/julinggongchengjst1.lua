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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2152709,
			sizeY = 0.05277778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xian",
				posX = 0.5,
				posY = 0,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.05263158,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pm10",
				varName = "rankTxt",
				posX = 0.4237877,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6904109,
				sizeY = 1.854458,
				text = "第一名",
				color = "FFFFEEB2",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pm11",
				varName = "name",
				posX = 0.7862831,
				posY = 0.5000005,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7826072,
				sizeY = 1.854458,
				text = "玩家名称",
				color = "FFFFEEB2",
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
