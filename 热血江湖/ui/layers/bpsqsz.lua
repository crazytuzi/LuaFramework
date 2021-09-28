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
			name = "ys2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.8800001,
			sizeY = 0.9800001,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "kong",
				varName = "kong",
				posX = 0.6082418,
				posY = 0.3784782,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1447088,
				sizeY = 0.09070295,
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
				sizeY = 0.3543084,
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
					posY = 0.616967,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8902509,
					sizeY = 0.5934542,
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
					posY = 0.567944,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.0375,
					sizeY = 1.108,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel",
					posX = 0.2505727,
					posY = 0.1570169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3395834,
					sizeY = 0.256,
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
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422305,
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
					name = "a2",
					varName = "ok",
					posX = 0.7540076,
					posY = 0.1570169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3395834,
					sizeY = 0.256,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "yes_name",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
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
					name = "anniu",
					posX = 0.1818642,
					posY = 0.6317877,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1041667,
					sizeY = 0.2,
					image = "sz#xzd",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an",
						varName = "open_btn",
						posX = 0.7900067,
						posY = 0.5499231,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.058265,
						sizeY = 1.058241,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ann",
						varName = "open_icon",
						posX = 0.5,
						posY = 0.52,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8399998,
						sizeY = 0.8399999,
						image = "sz#xzt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wz",
						varName = "open_str",
						posX = 2.366689,
						posY = 0.5199999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.496401,
						sizeY = 0.8837482,
						text = "开启推送",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "anniu2",
					posX = 0.6193582,
					posY = 0.6277877,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1041667,
					sizeY = 0.2,
					image = "sz#xzd",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an2",
						varName = "close_btn",
						posX = 0.5100067,
						posY = 0.5499231,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.058265,
						sizeY = 1.058241,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ann2",
						varName = "close_icon",
						posX = 0.5,
						posY = 0.52,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8399998,
						sizeY = 0.8399999,
						image = "sz#xzt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "close_str",
						posX = 2.366689,
						posY = 0.5199999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.496401,
						sizeY = 0.8837482,
						text = "开启推送",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
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
