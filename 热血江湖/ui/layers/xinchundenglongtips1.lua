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
			posX = 0.5007802,
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
				sizeY = 0.8611111,
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
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.9001275,
					sizeY = 0.5056221,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
					varName = "discountRoot",
					posX = 0.5,
					posY = 0.2874754,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8598635,
					sizeY = 0.1555959,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "sj3",
						varName = "btn",
						posX = 0.5,
						posY = 0.7068968,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3420515,
						sizeY = 0.5897881,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ff3",
							varName = "btn_label3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9625977,
							sizeY = 1.028664,
							text = "确 认",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
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
					name = "dt2",
					posX = 0.5,
					posY = 0.5006328,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7928147,
					sizeY = 0.210943,
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
						etype = "Image",
						name = "srk",
						posX = 0.5,
						posY = 0.255908,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8387114,
						sizeY = 0.3670155,
						image = "b#srk",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "EditBox",
							name = "srk1",
							sizeXAB = 339.1208,
							sizeYAB = 48,
							posXAB = 169.5604,
							posYAB = 24,
							varName = "answer",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							vTextAlign = 1,
							phText = "输入谜底",
						},
					},
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "wb1",
						varName = "quiz",
						posX = 0.5,
						posY = 0.7288753,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.817307,
						sizeY = 0.4577422,
						text = "小楼昨夜又东风（打一字）",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bt",
					posX = 0.5,
					posY = 0.6774194,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5470588,
					sizeY = 0.08064516,
					image = "chu1#zld",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "btwz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						text = "猜灯谜",
						color = "FF966856",
						fontSize = 22,
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
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.6582491,
				posY = 0.679846,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05078125,
				sizeY = 0.0875,
				image = "baishi#x",
				imageNormal = "baishi#x",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
