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
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3125,
				sizeY = 0.6111111,
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
					sizeY = 1.100401,
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
						posY = 0.8365337,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.2318037,
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
					name = "djd",
					varName = "item_bg",
					posX = 0.2115952,
					posY = 0.87119,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2375,
					sizeY = 0.2181818,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5459611,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
						image = "items#xueping1.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo2",
						posX = 0.1978613,
						posY = 0.2257828,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3157895,
						sizeY = 0.3125,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "hs",
						posX = 0.5,
						posY = 0.5312501,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.8421053,
						sizeY = 0.8333334,
						image = "ty#hong",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "item_name",
					posX = 0.6822011,
					posY = 0.9370552,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6189634,
					sizeY = 0.1250911,
					text = "道具名字一二三",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel",
					posX = 0.2305731,
					posY = 0.049157,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4075,
					sizeY = 0.1454545,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz1",
						varName = "cancel_word",
						posX = 0.4927007,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.963034,
						text = "取 消",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
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
					posX = 0.7666207,
					posY = 0.049157,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4075,
					sizeY = 0.1454545,
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
					name = "smd1",
					posX = 0.5,
					posY = 0.6089107,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.2495898,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "z2",
						varName = "desc",
						posX = 0.5,
						posY = -0.8216925,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8964135,
						sizeY = 1.083886,
						text = "提示条件写在这里",
						color = "FFC93034",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z5",
					varName = "item_type",
					posX = 0.6822011,
					posY = 0.8234192,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.6189634,
					sizeY = 0.1250911,
					text = "道具类型",
					color = "FF65944D",
					fontSize = 24,
					fontOutlineColor = "FFFCEBCF",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd2",
					posX = 0.5,
					posY = 0.6515578,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9291599,
					sizeY = 0.1363636,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z3",
						posX = 0.472757,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5005646,
						sizeY = 1,
						text = "申请数量：",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF37221A",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "z4",
						varName = "item_count",
						posX = 0.7082915,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3841274,
						sizeY = 1,
						text = "1111111",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF37221A",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd3",
					posX = 0.5,
					posY = 0.5607982,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9291599,
					sizeY = 0.1363636,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z6",
						posX = 0.472757,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5005646,
						sizeY = 1,
						text = "消耗点数：",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF37221A",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "z7",
						varName = "need_score",
						posX = 0.7082915,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3841274,
						sizeY = 1,
						text = "1111111",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF37221A",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd4",
					posX = 0.5,
					posY = 0.4700385,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9291599,
					sizeY = 0.1363636,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z8",
						posX = 0.472757,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5005646,
						sizeY = 1,
						text = "剩余点数：",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF37221A",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "z9",
						varName = "left_score",
						posX = 0.7082915,
						posY = 0.4999996,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3841274,
						sizeY = 1,
						text = "1111111",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF37221A",
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
