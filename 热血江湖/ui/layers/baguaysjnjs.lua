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
			posX = 0.4992199,
			posY = 0.5013853,
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
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3498418,
				sizeY = 0.6629555,
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
				sizeX = 0.3356418,
				sizeY = 0.7614998,
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
					posX = 0.5000001,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.093276,
					sizeY = 1.151715,
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
						posX = 0.5,
						posY = 0.8768409,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.1718616,
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
						name = "d5",
						posX = 0.5,
						posY = 0.4549531,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.2988335,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "top3",
							posX = 0.5,
							posY = 0.8569174,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6615031,
							sizeY = 0.1695795,
							image = "chu1#top3",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					posX = 0.2115952,
					posY = 0.9281146,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1862104,
					sizeY = 0.1459109,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "icon",
						posX = 0.4701211,
						posY = 0.4620144,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.3375,
						sizeY = 1.3375,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an",
						varName = "ItemInfo",
						posX = 0.5005332,
						posY = 0.5272427,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.935298,
						sizeY = 0.9554245,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wbk",
						varName = "level",
						posX = 3.3522,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.888368,
						sizeY = 0.553995,
						text = "[未启动]",
						color = "FFC93034",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djts",
						varName = "cover",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.3375,
						sizeY = 1.3375,
						image = "yishu#yuan",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "Active",
					posX = 0.5,
					posY = 0.003669228,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3375064,
					sizeY = 0.1003137,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						posX = 0.5064462,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.963034,
						text = "激 活",
						fontSize = 22,
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
					posX = 0.5502251,
					posY = 0.9281148,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3550121,
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
					name = "xjxg2",
					varName = "nextTitle",
					posX = 0.5,
					posY = 0.5656676,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3511388,
					sizeY = 0.09518068,
					text = "一阶效果",
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
						name = "smwz2",
						varName = "effect",
						posX = 0.4835732,
						posY = -1.557743,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.640306,
						sizeY = 1.93214,
						text = "级技能描述文字",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
						lineSpace = -3,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "smwz3",
						varName = "maxCount",
						posX = 0.5,
						posY = -0.2381195,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.673159,
						sizeY = 2.007756,
						text = "装备上限》",
						color = "FFC93034",
						hTextAlign = 1,
						vTextAlign = 1,
						lineSpace = -3,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wbk2",
					posX = 0.5395023,
					posY = 0.7694963,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5065899,
					sizeY = 0.1128948,
					text = "类型需求：",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wbk3",
					varName = "typeName",
					posX = 0.7172747,
					posY = 0.7694963,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.33695,
					sizeY = 0.1128948,
					text = "xx",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wbk4",
					posX = 0.5395023,
					posY = 0.6874208,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5065899,
					sizeY = 0.1128948,
					text = "专精需求：",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wbk5",
					varName = "neadZJ",
					posX = 0.7172747,
					posY = 0.6874208,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.33695,
					sizeY = 0.1128948,
					text = "xx",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "scroll",
				posX = 0.5,
				posY = 0.246263,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3842356,
				sizeY = 0.1416667,
				horizontal = true,
				showScrollBar = false,
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
