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
					posX = 0.5009773,
					posY = 0.4914811,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9141856,
					sizeY = 0.5272307,
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
					posY = 0.3153049,
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
						varName = "cancel",
						posX = 0.2477256,
						posY = 0.4896368,
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
							text = "取 消",
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
				{
					prop = {
						etype = "Button",
						name = "sj4",
						varName = "ok",
						posX = 0.7636596,
						posY = 0.4896368,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3420515,
						sizeY = 0.5897881,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ff4",
							varName = "discountDesc",
							posX = 0.4933333,
							posY = 0.5000001,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9625977,
							sizeY = 1.028664,
							text = "装 扮",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF347468",
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
					posY = 0.4951689,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8143478,
					sizeY = 0.1951613,
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
						varName = "scroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9302886,
						sizeY = 0.7603306,
						horizontal = true,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb",
				posX = 0.5,
				posY = 0.6290576,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.310139,
				sizeY = 0.06121656,
				text = "叮叮当，叮叮当，铃儿响叮当~",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.6621478,
				posY = 0.6853936,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05078125,
				sizeY = 0.0875,
				image = "baishi#x",
				imageNormal = "baishi#x",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.712941,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wb2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.833832,
					sizeY = 1.683724,
					text = "装扮圣诞树",
					color = "FF7F4920",
					fontSize = 22,
					fontOutlineColor = "FFFFFFFF",
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
