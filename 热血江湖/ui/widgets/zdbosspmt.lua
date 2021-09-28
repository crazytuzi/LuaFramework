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
			name = "d",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2,
			sizeY = 0.05135727,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "zd#bossmzd",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs",
				varName = "time_label",
				posX = 0.1607125,
				posY = 0.5319111,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2573819,
				sizeY = 1.35981,
				text = "排名",
				color = "FFFFFF00",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs2",
				posX = 0.3926642,
				posY = 0.5319115,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4798522,
				sizeY = 1.35981,
				text = "名字",
				color = "FFFFFF00",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs3",
				posX = 0.8217534,
				posY = 0.5319115,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.32365,
				sizeY = 1.35981,
				text = "伤害",
				color = "FFFFFF00",
				hTextAlign = 1,
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
	c_dakai = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
