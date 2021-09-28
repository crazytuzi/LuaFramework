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
		closeAfterOpenAni = true,
	},
	children = {
	{
		prop = {
			etype = "Grid",
			name = "pz",
			varName = "exproot",
			posX = 0.7443928,
			posY = 0.3354167,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3008529,
			sizeY = 0.6402778,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tp1",
				varName = "expbg1",
				posX = 0.3470405,
				posY = 0.8270116,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5037761,
				sizeY = 0.05422993,
				image = "zd#expd",
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "b1",
					posX = 0.2994305,
					posY = 0.54,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2330033,
					sizeY = 1.808105,
					image = "tb#tongqian",
					alphaCascade = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jc1",
					varName = "countLabel",
					posX = 1.05105,
					posY = 0.5202496,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.191005,
					sizeY = 1.644051,
					text = "+22",
					color = "FFA1FF26",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF120D23",
					vTextAlign = 1,
					alphaCascade = true,
					colorTL = "FFF6FF65",
					colorTR = "FFF6FF65",
					colorBR = "FFA1FF26",
					colorBL = "FFA1FF26",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					posX = 0.3198119,
					posY = 0.3403345,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.128866,
					sizeY = 1,
					image = "tb#suo",
				},
			},
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
	piao = {
		tp1 = {
			move = {{0, {133.6424,381.2524,0}}, {1000, {133.6424, 500, 0}}, },
			alpha = {{0, {1}}, {700, {1}}, {1000, {0}}, },
		},
	},
	c_dakai = {
		{0,"piao", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
