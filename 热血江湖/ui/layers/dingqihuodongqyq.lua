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
				name = "zz",
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
				name = "dn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
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
					name = "top1",
					posX = 0.5,
					posY = 0.9033331,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5854167,
					sizeY = 0.128,
					image = "chu1#top3",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "top2",
						posX = 0.5,
						posY = 0.4688158,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3410793,
						sizeY = 0.9983788,
						text = "祈愿",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
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
					name = "dt2",
					posX = 0.5,
					posY = 0.5658899,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9045273,
					sizeY = 0.4752217,
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
				etype = "Grid",
				name = "qyq",
				posX = 0.4988292,
				posY = 0.5097054,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6419141,
				sizeY = 0.6794384,
				hTextAlign = 1,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "fs2",
					varName = "ok",
					posX = 0.6725428,
					posY = 0.3040463,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2254333,
					sizeY = 0.1334969,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z2",
						posX = 0.4945908,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7722979,
						sizeY = 0.9325451,
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
					etype = "Button",
					name = "gb2",
					varName = "close",
					posX = 0.337778,
					posY = 0.3040463,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2254333,
					sizeY = 0.1334969,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z3",
						posX = 0.4945908,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7722979,
						sizeY = 0.9325451,
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
					etype = "EditBox",
					name = "qy2",
					sizeXAB = 367.8573,
					sizeYAB = 47.92158,
					posXAB = 364.5216,
					posYAB = 260.8148,
					varName = "txt",
					posX = 0.504143,
					posY = 0.5440309,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5087563,
					sizeY = 0.09995913,
					text = "一二三四五六七八九十",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
					phColor = "FF966856",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "qy3",
						posX = 0.5027211,
						posY = 0.4940802,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9999998,
						sizeY = 1.166607,
						image = "b#srk",
						scale9 = true,
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
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
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
