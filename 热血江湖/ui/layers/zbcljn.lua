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
				varName = "close_btn",
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
				etype = "Button",
				name = "gb",
				posX = 0.5007794,
				posY = 0.4993062,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3182276,
				sizeY = 0.6919188,
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
				sizeX = 0.3125,
				sizeY = 0.7545668,
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
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02,
					sizeY = 0.8748204,
					image = "b#db5",
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
						name = "dww",
						posX = 0.4975526,
						posY = 0.8470002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.2108705,
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
						name = "dww2",
						posX = 0.5,
						posY = 0.4380336,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.5482498,
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
						name = "top1",
						posX = 0.5,
						posY = 0.675167,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6887255,
						sizeY = 0.0673288,
						image = "chu1#top3",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					varName = "item_bg",
					posX = 0.3415951,
					posY = 0.8007879,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.205,
					sizeY = 0.1509328,
					image = "zdjn#lv",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "icon",
						posX = 0.5,
						posY = 0.511393,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7926056,
						sizeY = 0.7926058,
						image = "xinfa#hunji",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an",
						varName = "item_btn",
						posX = 0.5005332,
						posY = 0.5272427,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.935298,
						sizeY = 0.9554245,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "okBtn",
					posX = 0.5,
					posY = 0.1362903,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3756818,
					sizeY = 0.1049167,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "input_name",
						posX = 0.4927007,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.963034,
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
					etype = "Label",
					name = "z5",
					varName = "name",
					posX = 0.7086365,
					posY = 0.803017,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3968344,
					sizeY = 0.1250911,
					text = "坚固",
					color = "FF65944D",
					fontSize = 24,
					fontOutlineColor = "FFFCEBCF",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dqxg",
					varName = "curEffect",
					posX = 0.5,
					posY = 0.6474407,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3511388,
					sizeY = 0.09518068,
					text = "技能效果",
					color = "FFF1E9D7",
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "sxz2",
						varName = "des",
						posX = 0.5,
						posY = -1.937173,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.470028,
						sizeY = 4.247472,
						text = "气血+500\n气血+500",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
						lineSpace = -3,
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
