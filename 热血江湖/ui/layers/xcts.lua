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
				sizeX = 0.4517376,
				sizeY = 0.5621059,
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
					posY = 0.6353417,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8902509,
					sizeY = 0.635772,
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
					posX = 0.6347187,
					posY = 0.3535112,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8612577,
					sizeY = 0.6844301,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "closeBtn",
					posX = 0.9426081,
					posY = 0.9248644,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1124132,
					sizeY = 0.1556646,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
					visible = false,
					sizeX = 0.3009214,
					sizeY = 0.1998678,
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
						sizeX = 0.9103208,
						sizeY = 0.9422302,
						text = "前往购买",
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
					etype = "RichText",
					name = "z4",
					varName = "desc",
					posX = 0.5,
					posY = 0.7217165,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8279736,
					sizeY = 0.4679641,
					text = "血池容量：6000万",
					color = "FF966856",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "scroll",
					posX = 0.4999999,
					posY = 0.1697565,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8895183,
					sizeY = 0.2706406,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb2",
					varName = "hpText1",
					posX = 0.5318405,
					posY = 0.4676009,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6917733,
					sizeY = 0.1043583,
					text = "血气充盈：使用血池道具效果+50%",
					color = "FFC93034",
					vTextAlign = 1,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ts",
						posX = -0.0576885,
						posY = 0.4524275,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.08984999,
						sizeY = 0.8114911,
						image = "tong#tsf",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb3",
					varName = "hpText2",
					posX = 0.5318573,
					posY = 0.3812551,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6917733,
					sizeY = 0.1043583,
					text = "血气充盈：使用血池道具效果+50%",
					color = "FFC93034",
					vTextAlign = 1,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ts2",
						posX = -0.0576885,
						posY = 0.4524275,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.08984999,
						sizeY = 0.8114911,
						image = "tong#tsf",
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
