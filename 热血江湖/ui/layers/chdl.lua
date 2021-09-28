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
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4220992,
				sizeY = 0.4211986,
				image = "b#cs",
				scale9 = true,
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
					posY = 0.589978,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8902509,
					sizeY = 0.6474321,
					image = "b#d2",
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
						name = "bt",
						posX = 0.5,
						posY = 0.7853972,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.3925365,
						image = "d#bt",
						alpha = 0.5,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.5923982,
					posY = 0.4757671,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9217323,
					sizeY = 0.9133986,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "desc",
					posX = 0.3734285,
					posY = 0.4291028,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5672116,
					sizeY = 0.3324528,
					text = "感谢你参与文字",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "ok",
					posX = 0.5,
					posY = 0.1306369,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3016915,
					sizeY = 0.2110379,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "btnName",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "领 取",
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
					etype = "Image",
					name = "lao",
					posX = 0.5,
					posY = 0.7699494,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9476445,
					sizeY = 0.4220759,
					image = "ch/jianghulaosiji",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "dj1",
					varName = "bt",
					posX = 0.8381544,
					posY = 0.4506209,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1765644,
					sizeY = 0.3132595,
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dk",
						varName = "grade_icon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.98,
						sizeY = 0.98,
						image = "djk#ktong",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tp1",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.54,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.788,
						sizeY = 0.788,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "suo",
						posX = 0.1973507,
						posY = 0.2609761,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.2993952,
						sizeY = 0.3,
						image = "tb#suo",
					},
				},
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
