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
				etype = "Scroll",
				name = "lie2",
				varName = "headScroll",
				posX = 0.1148232,
				posY = 0.5838683,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1296875,
				sizeY = 0.4422751,
				showScrollBar = false,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7382813,
				sizeY = 0.7277778,
				image = "xiangced#xiangced",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.4854074,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9015103,
					sizeY = 0.7050488,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "photoScroll",
						posX = 0.25,
						posY = 0.5270675,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4589593,
						sizeY = 1.012328,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tsz",
						varName = "label",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.7424081,
						sizeY = 0.49038,
						text = "您的精灵还没有寄回来一张照片",
						color = "FF966856",
						fontSize = 24,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "photoScroll2",
						posX = 0.75,
						posY = 0.5270675,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4589593,
						sizeY = 1.012328,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "ys",
						varName = "pageNum",
						posX = 0.5,
						posY = -0.0566762,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "2/8",
						color = "FFFFFF80",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "shareBtn",
					posX = 0.5,
					posY = -0.008128813,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1534392,
					sizeY = 0.1049618,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						varName = "no_name",
						posX = 0.5,
						posY = 0.5105112,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422305,
						text = "分 享",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bg",
					varName = "cancel",
					posX = 0.9361091,
					posY = 0.8977059,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06878307,
					sizeY = 0.120229,
					image = "baishi#x",
					imageNormal = "baishi#x",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "fan1",
					varName = "forward",
					posX = 1,
					posY = 0.143693,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04550264,
					sizeY = 0.1030534,
					image = "lxsy#jt",
					imageNormal = "lxsy#jt",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "fan2",
					varName = "backward",
					posX = 0,
					posY = 0.143693,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04550264,
					sizeY = 0.1030534,
					image = "lxsy#jt",
					imageNormal = "lxsy#jt",
					disablePressScale = true,
					flippedX = true,
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
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
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
