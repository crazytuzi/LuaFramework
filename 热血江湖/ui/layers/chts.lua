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
		soundEffectOpen = "audio/rxjh/UI/ui_jiangli2.ogg",
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
				varName = "ok",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
				name = "dg",
				posX = 0.5,
				posY = 0.6497473,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1867188,
				sizeY = 0.3319444,
				image = "top#dg2",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jd",
				posX = 0.5,
				posY = 0.5236112,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7800573,
				sizeY = 0.2498392,
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt",
					varName = "dt",
					posX = 0.5,
					posY = 0.2476445,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.131728,
					sizeY = 1.504711,
					image = "d#diban",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alphaCascade = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "chdt",
					varName = "bg",
					posX = 0.5,
					posY = 0.5833877,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5127828,
					sizeY = 0.7115688,
					image = "ch/zpwxd",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "chtp",
					varName = "icon",
					posX = 0.5,
					posY = 0.5833874,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1281957,
					sizeY = 0.3557844,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sx",
					varName = "time",
					posX = 0.5,
					posY = -0.3172567,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.413443,
					text = "时效：多久",
					color = "FF911D02",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sxd",
					posX = 0.5,
					posY = 0.0602245,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.448685,
					sizeY = 0.452776,
					image = "d#tyd",
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.5,
					posY = 0.06022453,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.448685,
					sizeY = 0.452776,
					showScrollBar = false,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dg2",
				posX = 0.5,
				posY = 0.6705808,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1765625,
				sizeY = 0.09166667,
				image = "top#hdjl",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz1",
				posX = 0.3705504,
				posY = 0.2488863,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				image = "tong#zsx2",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sz2",
				posX = 0.6302946,
				posY = 0.2488863,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0890625,
				sizeY = 0.0125,
				image = "tong#zsx2",
				alpha = 0,
				flippedX = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "xs",
				posX = 0.5,
				posY = 0.2486416,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3881353,
				sizeY = 0.08617477,
				text = "点击空白区域继续",
				fontSize = 22,
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
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
	zi = {
		dg2 = {
			move = {{0, {640, 1100, 0}}, {300, {640,482.8182,0}}, {350, {640, 500, 0}}, {400, {640,482.8182,0}}, },
			alpha = {{0, {1}}, },
		},
	},
	guang = {
		dg = {
			rotate = {{0, {0}}, {3000, {180}}, },
			alpha = {{0, {1}}, },
		},
	},
	dg2 = {
		sz1 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		sz2 = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
		xs = {
			alpha = {{0, {0}}, {300, {1}}, },
		},
	},
	dk2 = {
		jd = {
			scale = {{0, {0, 0, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"zi", 1, 0},
		{0,"guang", -1, 300},
		{0,"dg2", 1, 200},
		{0,"dk2", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
