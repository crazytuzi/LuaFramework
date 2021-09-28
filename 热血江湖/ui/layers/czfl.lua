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
				sizeX = 0.4504992,
				sizeY = 0.5774828,
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
					posY = 0.5753987,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8902509,
					sizeY = 0.7616219,
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
						name = "bt",
						posX = 0.5,
						posY = 0.8489711,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.27802,
						image = "d#bt",
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "RichText",
							name = "z2",
							varName = "expression",
							posX = 0.5000001,
							posY = 0.4714563,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8972613,
							sizeY = 0.8476693,
							text = "感谢参与xxx活动",
							color = "FF966856",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.6149232,
					posY = 0.3485884,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8636253,
					sizeY = 0.6662055,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "desc",
					posX = 0.5000001,
					posY = 0.6634619,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7987878,
					sizeY = 0.1031072,
					text = "您可以领取以下奖励（该奖励只可领取一次）",
					color = "FF966856",
					fontOutlineColor = "FF27221D",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "ok",
					posX = 0.5,
					posY = 0.09777502,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2826725,
					sizeY = 0.1539247,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "btnName",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "领 取",
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
					etype = "Scroll",
					name = "lb",
					varName = "pet_scroll",
					posX = 0.5,
					posY = 0.3397387,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz1",
					varName = "viptext",
					posX = 0.4945669,
					posY = 0.6009089,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4644768,
					sizeY = 0.1057905,
					text = "贵族特权点数：",
					color = "FF65944D",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz2",
					varName = "vipnumber",
					posX = 0.7651021,
					posY = 0.6009089,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4644768,
					sizeY = 0.1057905,
					text = "8000",
					color = "FF65944D",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz3",
					varName = "diamondtext",
					posX = 0.4945669,
					posY = 0.5167317,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4644768,
					sizeY = 0.1057905,
					text = "元宝数量：",
					color = "FF65944D",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz4",
					varName = "diamondnumber",
					posX = 0.7651021,
					posY = 0.5167317,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4644768,
					sizeY = 0.1057905,
					text = "150000",
					color = "FF65944D",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9690679,
					posY = 0.9229593,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1161905,
					sizeY = 0.1827856,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
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
