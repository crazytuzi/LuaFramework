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
				varName = "imgBK",
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
				posX = 0.5007855,
				posY = 0.5652783,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.353125,
				sizeY = 0.3416667,
				image = "xj#xj3",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.6599051,
				posY = 0.644313,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03125,
				sizeY = 0.05555556,
				image = "xj#xj1",
				imageNormal = "xj#xj1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a2",
				varName = "btn1",
				posX = 0.4001577,
				posY = 0.5266144,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.1111111,
				image = "xj#kj",
				imageNormal = "xj#kj",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "red1",
					posX = 0.836956,
					posY = 0.8619743,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.35,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a3",
				varName = "btn2",
				posX = 0.4992459,
				posY = 0.5266144,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.1111111,
				image = "xj#dati",
				imageNormal = "xj#dati",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hd2",
					varName = "red2",
					posX = 0.836956,
					posY = 0.8619743,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.35,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a4",
				varName = "btn3",
				posX = 0.5986758,
				posY = 0.5293922,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0625,
				sizeY = 0.1111111,
				image = "xj#wjzb",
				imageNormal = "xj#wjzb",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hd3",
					varName = "red3",
					posX = 0.836956,
					posY = 0.8369743,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3375,
					sizeY = 0.35,
					image = "zdte#hd",
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
