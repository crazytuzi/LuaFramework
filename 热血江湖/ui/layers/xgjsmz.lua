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
			sizeX = 0.88,
			sizeY = 0.98,
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
				sizeX = 0.4261363,
				sizeY = 0.3837316,
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
					name = "smd",
					posX = 0.5,
					posY = 0.6005689,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9045273,
					sizeY = 0.6214832,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.5,
					posY = 0.5347043,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.0375,
					sizeY = 1.023042,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "item_count",
					posX = 0.4574912,
					posY = 0.8009606,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7217302,
					sizeY = 0.1667769,
					text = "为你的角色取个名字：",
					color = "FF966856",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "changge_btn",
					posX = 0.7540076,
					posY = 0.1585505,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3395834,
					sizeY = 0.2363708,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz1",
						varName = "cancel_word",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313715,
						sizeY = 0.8905213,
						text = "确 定",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFB35F1D",
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
					name = "zd",
					posX = 0.5,
					posY = 0.6034663,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5454289,
					sizeY = 0.1846647,
					image = "b#srk",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "EditBox",
						name = "mz",
						sizeXAB = 224.6204,
						sizeYAB = 52.79351,
						posXAB = 130.9029,
						posYAB = 25,
						varName = "input_label",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8579655,
						sizeY = 1.05587,
						color = "FFFFF4E4",
						fontSize = 26,
						vTextAlign = 1,
						inputWidth = 300,
						inputHeight = 50,
						phText = "2~7个汉字",
						phColor = "FFFFF4E4",
						phFontSize = 26,
						autoWrap = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z3",
					posX = 0.2624035,
					posY = 0.4059794,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2859592,
					sizeY = 0.1447914,
					text = "花费：",
					color = "FF966856",
					fontSize = 24,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "yb",
					varName = "item_icon",
					posX = 0.4995753,
					posY = 0.4059794,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1041667,
					sizeY = 0.1846647,
					image = "tb#tb_yuanbao.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z4",
					varName = "ingot_count",
					posX = 0.7778986,
					posY = 0.4059794,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3997518,
					sizeY = 0.1447914,
					text = "x500",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "cancel_btn",
					posX = 0.2484894,
					posY = 0.1585505,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3395834,
					sizeY = 0.2363708,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "cancel_word2",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313715,
						sizeY = 0.8905213,
						text = "取 消",
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
					name = "sz",
					varName = "random_btn",
					posX = 0.7516671,
					posY = 0.6179938,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1604167,
					sizeY = 0.2806903,
					image = "dl#sz",
					imageNormal = "dl#sz",
					disablePressScale = true,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
