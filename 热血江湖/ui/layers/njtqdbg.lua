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
				varName = "close",
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
				sizeX = 0.3442227,
				sizeY = 0.3637932,
				image = " b#cs",
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "zz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5022359,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02,
					sizeY = 1.025528,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dww",
						posX = 0.5,
						posY = 0.5425494,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9317993,
						sizeY = 0.3719645,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "k1",
					posX = 0.5,
					posY = 0.5422699,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9215351,
					sizeY = 0.2401473,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "sld",
						posX = 0.3640641,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6033992,
						sizeY = 1.112841,
						image = "sl#sld",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "jian",
						varName = "jian",
						posX = 0.1059266,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.135457,
						sizeY = 1.112841,
						image = "sl#jian",
						imageNormal = "sl#jian",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl",
						varName = "sale_count",
						posX = 0.364327,
						posY = 0.4764549,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4089706,
						sizeY = 0.58996,
						text = "231/999",
						fontSize = 26,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2E1410",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "jia",
						varName = "jia",
						posX = 0.6240963,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.135457,
						sizeY = 1.112841,
						image = "sl#jia",
						imageNormal = "sl#jia",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "max",
						varName = "max",
						posX = 0.8605369,
						posY = 0.4905361,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2068797,
						sizeY = 1.319512,
						image = "sl#max",
						imageNormal = "sl#max",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "ok",
					posX = 0.5,
					posY = 0.180876,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4346333,
					sizeY = 0.2443391,
					image = "chu1#an1",
					scale9 = true,
					scale9Left = 0.49,
					scale9Right = 0.49,
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "ok_word",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.963034,
						scale9Left = 0.49,
						scale9Right = 0.49,
						text = "提取到背包",
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
					etype = "Label",
					name = "tqs",
					posX = 0.5,
					posY = 0.8706241,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "请选择提取数量",
					color = "FF966856",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
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
