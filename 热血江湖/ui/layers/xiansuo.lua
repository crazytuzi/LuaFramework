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
			sizeX = 0.6,
			sizeY = 0.6,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.4699568,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6869993,
				sizeY = 0.790368,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5033069,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02,
					sizeY = 1.02,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.25,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5,
					posY = 0.5628213,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9123119,
					sizeY = 0.6287418,
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
					etype = "Label",
					name = "z2",
					varName = "descLabel",
					posX = 0.4962094,
					posY = 0.4047008,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8407664,
					sizeY = 0.2490795,
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dg",
					posX = 0.5,
					posY = 0.7108736,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3982753,
					sizeY = 0.6154427,
					image = "hd#dg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "okBtn",
					posX = 0.5,
					posY = 0.1138757,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3089371,
					sizeY = 0.187442,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz1",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313715,
						sizeY = 0.8359765,
						text = "确 定",
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
					name = "top",
					posX = 0.5,
					posY = 1.014267,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5003644,
					sizeY = 0.1522966,
					image = "chu1#top",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tt",
						posX = 0.5,
						posY = 0.5174515,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5075758,
						sizeY = 0.4807692,
						image = "biaoti#faxianxiansuo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djk",
					posX = 0.5,
					posY = 0.7108736,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1800554,
					sizeY = 0.281163,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "icon",
						posX = 0.5,
						posY = 0.5416668,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
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
