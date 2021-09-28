--version = 1
local l_fileType = "layer"

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
			name = "sss",
			varName = "tips_root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 1,
			sizeX = 0.2987693,
			sizeY = 0.1866256,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "tips_bg",
				posX = 0.5,
				posY = 1,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 1,
				sizeY = 1,
				image = "b#bp",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z1",
				varName = "desc",
				posX = 0.5,
				posY = 0.9257016,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 0.9148533,
				sizeY = 0.862316,
				text = "文字介绍提示写在这。写多少是多少",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
