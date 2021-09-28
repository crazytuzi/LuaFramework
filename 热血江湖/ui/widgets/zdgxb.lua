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
			name = "lb1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6992188,
			sizeY = 0.1,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "p31",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "d#bt",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp",
				varName = "rankImg",
				posX = 0.07455194,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1418448,
				sizeY = 0.8472222,
				image = "cl3#1st",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "w31",
				varName = "rankLabel",
				posX = 0.07455195,
				posY = 0.4999998,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1418448,
				sizeY = 0.8472222,
				text = "4",
				color = "FF966856",
				fontSize = 26,
				fontOutlineColor = "FF804000",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "w32",
				varName = "playerName",
				posX = 0.3684886,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3641216,
				sizeY = 1,
				text = "名字最长七个字",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF804000",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "w33",
				varName = "donateCount",
				posX = 0.7904959,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3601174,
				sizeY = 1,
				text = "999999",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF804000",
				fontOutlineSize = 2,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
