--version = 1
local l_fileType = "node"

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
			name = "xiansuo",
			varName = "xiansuoRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.29375,
			sizeY = 0.7763889,
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "j4",
				posX = 0.5000002,
				posY = 0.3070518,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.3509817,
				scale9 = true,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top4",
					posX = 0.5,
					posY = 1,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7473404,
					sizeY = 0.1630999,
					image = "chu1#top3",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z33",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6391395,
						sizeY = 1.573519,
						text = "需求",
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
					etype = "Label",
					name = "z31",
					varName = "name",
					posX = 0.5,
					posY = 0.3013935,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7760856,
					sizeY = 0.3347325,
					text = "书法名称一二三四x1",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djk",
					varName = "bg",
					posX = 0.5,
					posY = 0.607118,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2656888,
					sizeY = 0.4893267,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "t",
						varName = "icon",
						posX = 0.4894737,
						posY = 0.5416668,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7612201,
						sizeY = 0.7532909,
						image = "items#items_gaojijinengshu.png",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "dj1",
						varName = "btn",
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
					etype = "Label",
					name = "z32",
					varName = "count",
					posX = 0.5000001,
					posY = 0.1405416,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6391395,
					sizeY = 0.3347325,
					text = "100/1000",
					color = "FF65944D",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "j6",
				posX = 0.5000002,
				posY = 0.780737,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.3509817,
				scale9 = true,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "hdt",
					varName = "desc",
					posX = 0.5,
					posY = 0.3565558,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7424868,
					sizeY = 1.190714,
					text = "可配置文本",
					color = "FF966856",
					fontOutlineColor = "FF400000",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an2",
				varName = "activeBtn",
				posX = 0.5000002,
				posY = 0.08239568,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.462766,
				sizeY = 0.118068,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z41",
					varName = "up_btn_label",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7194395,
					sizeY = 0.8147679,
					text = "激 活",
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
		},
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
