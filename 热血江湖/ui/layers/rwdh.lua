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
				varName = "closebtn",
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
				name = "fazhen",
				posX = 0.5,
				posY = 0.527778,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5709358,
				sizeY = 1.014997,
				image = "uieffect/gh.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zuodao",
				posX = 0.5195389,
				posY = 0.5552417,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4,
				sizeY = 0.7111111,
				image = "uieffect/zuodao.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "youdao",
				posX = 1.193503,
				posY = 0.8938069,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4,
				sizeY = 0.7111111,
				image = "uieffect/youdao.png",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tianshu",
				posX = 0.5,
				posY = 0.5166668,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5054181,
				sizeY = 0.8985207,
				image = "uieffect/tianshu.png",
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
	fazhen = {
		fazhen = {
			rotate = {{0, {0}}, {6000, {180}}, {9000, {270}}, {12000, {360}}, },
			alpha = {{0, {0}}, {1000, {1}}, },
		},
	},
	youdao = {
		youdao = {
			alpha = {{0, {1}}, },
			move = {{0, {1532.675, 772.3275, 0}}, {100, {964.6097, 425, 0}}, },
		},
	},
	zuodao = {
		zuodao = {
			alpha = {{0, {0}}, {50, {1}}, },
			move = {{0, {665.0098,399.774,0}}, {100, {393.4572, 304.9307, 0}}, },
		},
	},
	tianshu = {
		tianshu = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {0}}, {50, {1}}, },
		},
	},
	c_dakai = {
		{0,"youdao", 1, 150},
		{0,"zuodao", 1, 200},
		{0,"fazhen", 1, 300},
		{0,"tianshu", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
