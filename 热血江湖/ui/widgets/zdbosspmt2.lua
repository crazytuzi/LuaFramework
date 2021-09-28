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
				varName = "rankLabel",
				posX = 0.1353603,
				posY = 0.5319111,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2066774,
				sizeY = 1.35981,
				text = "20",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs2",
				varName = "nameLabel",
				posX = 0.3926642,
				posY = 0.5319115,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5859375,
				sizeY = 1.35981,
				text = "六个字六个字",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs3",
				varName = "damageLabel",
				posX = 0.8217534,
				posY = 0.5319115,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4296875,
				sizeY = 1.35981,
				text = "20000000",
				fontSize = 18,
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
