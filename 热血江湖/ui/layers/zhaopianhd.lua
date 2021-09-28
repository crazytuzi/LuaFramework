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
				varName = "cancel",
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
				name = "top",
				varName = "topImage",
				posX = 0.4953168,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7296875,
				sizeY = 0.9486111,
				image = "zhaopian#zhaopian",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "topz",
					varName = "topTitle",
					posX = 0.5114288,
					posY = 0.8978478,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9315339,
					sizeY = 0.2079539,
					text = "xxx的照片",
					color = "FF3B9174",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zp",
				varName = "icon",
				posX = 0.4999943,
				posY = 0.4674816,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.65625,
				sizeY = 0.7083333,
				image = "tzp1#tzp1",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btn",
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
				etype = "Button",
				name = "you",
				varName = "rightBtn",
				posX = 0.8642381,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03359375,
				sizeY = 0.075,
				image = "chu1#jiantou",
				imageNormal = "chu1#jiantou",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "zuo",
				varName = "leftBtn",
				posX = 0.1371243,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03359375,
				sizeY = 0.075,
				image = "chu1#jiantou",
				imageNormal = "chu1#jiantou",
				disablePressScale = true,
				flippedX = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tsz",
				posX = 0.5,
				posY = 0.0860756,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.1680271,
				text = "点击空白区域关闭",
				color = "FF3B9174",
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
