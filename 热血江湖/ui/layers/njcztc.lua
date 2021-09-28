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
				posX = 0.5007802,
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
				posX = 0.5005721,
				posY = 0.4993639,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3139614,
				sizeY = 0.4757218,
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
				sizeY = 0.4689241,
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
					posY = 0.5022359,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02,
					sizeY = 1.025528,
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
						posY = 0.6637098,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.2912245,
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
						name = "zsx1",
						posX = 0.5,
						posY = 0.8979081,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6887255,
						sizeY = 0.0924203,
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
					posX = 0.2115952,
					posY = 0.6616171,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2375,
					sizeY = 0.2754532,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.513703,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8158965,
						sizeY = 0.8,
						image = "items#xueping1.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wpmc",
						varName = "item_name",
						posX = 2.15519,
						posY = 0.7559893,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.955723,
						sizeY = 0.5045484,
						text = "五虎断门刀谱",
						color = "FF911D02",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl",
						varName = "item_count",
						posX = 1.656001,
						posY = 0.3497393,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9573454,
						sizeY = 0.4433545,
						text = "0/1",
						color = "FF911D02",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "wpan",
						varName = "item_btn",
						posX = 0.4952771,
						posY = 0.5251675,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9247858,
						sizeY = 0.9232125,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "item_suo",
						posX = 0.1951911,
						posY = 0.2316195,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3157895,
						sizeY = 0.3225807,
						image = "tb#suo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "reset_btn",
					posX = 0.5,
					posY = 0.1442746,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4075,
					sizeY = 0.1895592,
					image = "chu1#an1",
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
						text = "重 置",
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
					name = "z5",
					posX = 0.5,
					posY = 0.9102674,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6189634,
					sizeY = 0.1250911,
					text = "重置消耗",
					color = "FFF1E9D7",
					fontOutlineEnable = true,
					fontOutlineColor = "FFA47848",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "xjxg",
					posX = 0.5,
					posY = 0.3732073,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8965183,
					sizeY = 0.1472891,
					text = "重置次数越多，消耗越多",
					color = "FFC93034",
					fontSize = 22,
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
