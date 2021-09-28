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
				posX = 0.5000001,
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
				name = "suicong",
				varName = "UIRoot",
				posX = 0.5,
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7425287,
				sizeY = 0.7543149,
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
					name = "gsa",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "hua",
						posX = 0.7941501,
						posY = 0.2683905,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5239697,
						sizeY = 0.5100287,
						image = "hua1#hua1",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9800723,
					posY = 0.9399784,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07049391,
					sizeY = 0.1399357,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8543489,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hyt",
					varName = "titleImg",
					posX = 0.5,
					posY = 0.5163934,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#tjhy2",
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "k1",
				posX = 0.5,
				posY = 0.4657708,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7050901,
				sizeY = 0.6921271,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5,
					posY = 0.924197,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.1302218,
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					alpha = 0.5,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "haoyou",
					varName = "ShouChong",
					posX = 0.5,
					posY = 0.4265868,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.003318,
					sizeY = 0.8531738,
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
						etype = "Scroll",
						name = "lb",
						varName = "friend_scroll",
						posX = 0.5,
						posY = 0.5004832,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.9758013,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an10",
					varName = "find_btn",
					posX = 0.6296106,
					posY = 0.9240849,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1373938,
					sizeY = 0.1163884,
					image = "chu1#sn1",
					imageNormal = "chu1#sn1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z4",
						varName = "GetBtnText3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 0.8880838,
						text = "查 找",
						color = "FF914A15",
						fontSize = 24,
						fontOutlineColor = "FF8DE3C4",
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
					name = "srk",
					posX = 0.2673447,
					posY = 0.922231,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5014192,
					sizeY = 0.1166008,
					image = "chu1#sxd",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "EditBox",
						name = "sr",
						sizeXAB = 412.0153,
						sizeYAB = 47.17717,
						posXAB = 224.4843,
						posYAB = 29.05293,
						varName = "editbox",
						posX = 0.4960558,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9104535,
						sizeY = 0.8119177,
						color = "FFF1DDC1",
						fontSize = 24,
						vTextAlign = 1,
						phText = "输入ID查找",
						phColor = "FFF1DDC1",
						phFontSize = 24,
						autoWrap = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an9",
					varName = "sysrecommend",
					posX = 0.8058729,
					posY = 0.9240848,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1373938,
					sizeY = 0.1163884,
					image = "chu1#sn1",
					imageNormal = "chu1#sn1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z3",
						varName = "GetBtnText2",
						posX = 0.5,
						posY = 0.5000015,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 0.8880838,
						text = "系统推荐",
						color = "FF914A15",
						fontSize = 24,
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
