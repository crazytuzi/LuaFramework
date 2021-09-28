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
			etype = "Image",
			name = "d",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
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
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.8,
			sizeY = 0.8,
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
				sizeX = 0.647275,
				sizeY = 0.2290204,
				image = "d#tst",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "desc",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8908252,
					sizeY = 0.5807464,
					text = "连接中。。。。",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dizhuan",
				posX = 0.3778881,
				posY = 0.500002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.125,
				sizeY = 0.2222222,
				image = "uieffect/guang1.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dizhuan2",
				posX = 0.3778881,
				posY = 0.500002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.125,
				sizeY = 0.2222222,
				image = "uieffect/guang3.png",
				alpha = 0,
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
	dizhuan2 = {
		dizhuan2 = {
			rotate = {{0, {0}}, {3000, {1800}}, },
			alpha = {{0, {1}}, },
		},
	},
	dizhuan = {
		dizhuan = {
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"dizhuan2", -1, 0},
		{0,"dizhuan", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
