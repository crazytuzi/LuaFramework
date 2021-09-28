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
			varName = "sb_root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.09609375,
			sizeY = 0.1111111,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "select1_btn",
				posX = 0.4879065,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9614763,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t1",
				varName = "xinfaBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9593496,
				sizeY = 0.9375001,
				image = "rcb#putong",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.5,
				posY = 0.675,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.104981,
				sizeY = 0.4981425,
				text = "心法名字六字",
				color = "FFCD8158",
				fontSize = 18,
				fontOutlineColor = "FF00152E",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "time",
				posX = 0.5,
				posY = 0.3,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.104981,
				sizeY = 0.4981425,
				text = "9至12点",
				color = "FFCD8158",
				fontSize = 16,
				fontOutlineColor = "FF00152E",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pvp",
				varName = "pvp",
				posX = 0.1185119,
				posY = 0.8369412,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2113821,
				sizeY = 0.3375,
				image = "rcb#pvp2",
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
