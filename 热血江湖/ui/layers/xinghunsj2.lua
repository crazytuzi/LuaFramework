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
				sizeX = 0.3984375,
				sizeY = 0.7480088,
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
					name = "wasd",
					posX = 0.5019608,
					posY = 0.5111408,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.152941,
					sizeY = 1.13635,
					image = "xinghundb#xinghundb",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk1",
					posX = 0.5,
					posY = 0.8596745,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8635877,
					sizeY = 0.1558134,
					image = "b#xhdb",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "wb1",
						varName = "cond1",
						posX = 0.6666072,
						posY = 0.4522243,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8319112,
						sizeY = 0.5420268,
						text = "条件1",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "top5",
						posX = 0.5,
						posY = 0.9967328,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4404789,
						sizeY = 0.4290012,
						image = "b#xht",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "taz5",
							varName = "now_effect",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7293959,
							sizeY = 0.9861619,
							text = "升阶条件",
							color = "FFF1E9D7",
							fontSize = 22,
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
						name = "gxd",
						posX = 0.1781152,
						posY = 0.4522242,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06811529,
						sizeY = 0.357501,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj1",
							varName = "mark1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.266667,
							sizeY = 1.133333,
							image = "chu1#dj",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk2",
					varName = "next",
					posX = 0.5,
					posY = 0.5853664,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8635877,
					sizeY = 0.2599494,
					image = "b#xhdb",
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
						name = "top4",
						posX = 0.5,
						posY = 0.9967328,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4404789,
						sizeY = 0.2571429,
						image = "b#xht",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "taz4",
							varName = "effectTitle",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7293959,
							sizeY = 0.9861619,
							text = "效果",
							color = "FFF1E9D7",
							fontSize = 22,
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
						etype = "RichText",
						name = "fwb",
						varName = "effect",
						posX = 0.5022672,
						posY = 0.4268475,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9097618,
						sizeY = 0.7529083,
						color = "FF966856",
						fontSize = 22,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk3",
					varName = "items",
					posX = 0.5,
					posY = 0.2575336,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8635877,
					sizeY = 0.2809972,
					image = "b#xhdb",
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
						name = "top3",
						posX = 0.5,
						posY = 0.9967328,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4404789,
						sizeY = 0.2378819,
						image = "b#xht",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "taz3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7293959,
							sizeY = 0.9861619,
							text = "消耗内容",
							color = "FFF1E9D7",
							fontSize = 22,
							fontOutlineColor = "FFA47848",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
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
					posY = 0.2395372,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8507923,
					sizeY = 0.2317182,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "sj2",
					varName = "up_stage_btn",
					posX = 0.501958,
					posY = 0.04557272,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3101604,
					sizeY = 0.1114069,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ff2",
						varName = "up_stage_label",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9625977,
						sizeY = 1.028664,
						text = "升 阶",
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
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8973404,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz",
					varName = "title_desc",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#xhsj",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.6816394,
				posY = 0.8576195,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "jt",
				varName = "rightBtn",
				posX = 0.7039064,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03359375,
				sizeY = 0.075,
				image = "chu1#jiantou",
				imageNormal = "chu1#jiantou",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "jt2",
				varName = "leftBtn",
				posX = 0.2968751,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03359375,
				sizeY = 0.075,
				image = "chu1#jiantou",
				imageNormal = "chu1#jiantou",
				disablePressScale = true,
				flippedX = true,
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
