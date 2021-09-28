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
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
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
			sizeX = 1,
			sizeY = 1,
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
				sizeX = 0.7929688,
				sizeY = 0.8055556,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.261084,
					sizeY = 1.241379,
					image = "fanfanlebj#fanfanlebj",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.9650654,
					posY = 0.9355491,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09458128,
					sizeY = 0.1637931,
					image = "ygst#gb",
					imageNormal = "ygst#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
					posX = 0.5000001,
					posY = 0.4396565,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb1",
						varName = "timeLabel",
						posX = 0.8756746,
						posY = 1.007482,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1809843,
						sizeY = 0.1370086,
						text = "0.20833333333333334",
						color = "FFFFF36C",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb2",
						posX = 0.7851838,
						posY = 1.007482,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1573763,
						sizeY = 0.1370086,
						text = "倒数：",
						color = "FFFFF36C",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb3",
						posX = 0.5570176,
						posY = -0.0236199,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1809843,
						sizeY = 0.1370086,
						text = "消除所有卡片",
						color = "FF64CAFF",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb4",
						posX = 0.4852457,
						posY = -0.0236199,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1573763,
						sizeY = 0.1370086,
						text = "目标：",
						color = "FF64CAFF",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.4995058,
						posY = 0.4764641,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8275862,
						sizeY = 0.8169262,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb5",
						varName = "num",
						posX = 0.5,
						posY = 1.007482,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2449162,
						sizeY = 0.1791284,
						text = "剩余次数：10",
						color = "FFFFF36C",
						hTextAlign = 1,
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
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1477832,
					sizeY = 0.2586207,
					image = "ggy#xxx",
					alpha = 0,
					alphaCascade = true,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	cuowu = {
		djt2 = {
			alpha = {{0, {1}}, {500, {1}}, {1200, {0}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
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
