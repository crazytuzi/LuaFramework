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
			name = "xjd",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tp2",
				posX = 0.5,
				posY = 0.8249937,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.25,
				sizeY = 0.3388889,
				image = "dadishu#hei",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp",
				posX = 0.498439,
				posY = 0.9083254,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9968001,
				sizeY = 0.1722222,
				image = "dadishu#db",
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "exit",
				posX = 0.9570372,
				posY = 0.8910062,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08359375,
				sizeY = 0.2166667,
				image = "dadishu#x",
				imageNormal = "dadishu#x",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs",
				posX = 0.5251582,
				posY = 0.9170759,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.232142,
				sizeY = 0.1424603,
				text = "倒数：",
				color = "FFFFE867",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF602C18",
				fontOutlineSize = 2,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs2",
				varName = "time",
				posX = 0.7726501,
				posY = 0.9170761,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2456904,
				sizeY = 0.1424603,
				text = "1:00",
				color = "FFFFE867",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF602C18",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "headIcon",
				posX = 0.0327954,
				posY = 0.8882592,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.2222222,
				image = "items6#pangxie",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "djs3",
					varName = "count",
					posX = 2.179868,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.30559,
					sizeY = 0.9537446,
					text = "x10",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djt2",
				varName = "false_icon",
				posX = 0.5,
				posY = 0.205314,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1171875,
				sizeY = 0.4166667,
				image = "ggy#xxx",
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "miao",
					varName = "punishTime",
					posX = 1.817758,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.38455,
					sizeY = 0.5683895,
					text = "-10秒",
					color = "FFC93034",
					fontSize = 40,
					fontOutlineEnable = true,
					fontOutlineColor = "FFFFFFFF",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "djs4",
				varName = "left_times",
				posX = 0.4434675,
				posY = 0.9170761,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2846885,
				sizeY = 0.1424603,
				text = "剩余次数：1",
				color = "FFFFE867",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF602C18",
				fontOutlineSize = 2,
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
	cuowu = {
		djt2 = {
			alpha = {{0, {1}}, {500, {1}}, {1200, {0}}, },
		},
	},
	c_cuo = {
		{0,"cuowu", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
