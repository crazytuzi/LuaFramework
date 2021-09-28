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
				sizeX = 0.4261363,
				sizeY = 0.4877548,
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
					posY = 0.6464053,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8902509,
					sizeY = 0.5998415,
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
						etype = "Scroll",
						name = "lb",
						varName = "content",
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
					etype = "Image",
					name = "hua",
					posX = 0.6006867,
					posY = 0.4116253,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9130002,
					sizeY = 0.7887616,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel",
					posX = 0.2505727,
					posY = 0.1199994,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.319,
					sizeY = 0.187936,
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
						posY = 0.5468748,
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
					posY = 0.1199994,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.319,
					sizeY = 0.187936,
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
						text = "合 并",
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
					name = "tp1",
					posX = 0.4518327,
					posY = 0.2738165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05500001,
					sizeY = 0.08542544,
					image = "chu1#gxd",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "markImg",
					posX = 0.4580797,
					posY = 0.2817716,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06966668,
					sizeY = 0.0968155,
					image = "chu1#dj",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "markBtn",
					posX = 0.4536673,
					posY = 0.2880951,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1294445,
					sizeY = 0.1396707,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					varName = "desc_1",
					posX = 0.8178994,
					posY = 0.2738213,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "全选",
					color = "FFC93034",
					fontSize = 22,
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
