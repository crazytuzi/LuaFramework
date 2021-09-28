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
				sizeY = 0.7563286,
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
					sizeX = 1,
					sizeY = 0.9606733,
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
						etype = "Label",
						name = "tswb2",
						varName = "tips",
						posX = 0.5,
						posY = 0.2035719,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8221794,
						sizeY = 0.1447436,
						text = "该技能战斗时自动释放",
						color = "FFC93034",
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
					name = "kk1",
					posX = 0.5,
					posY = 0.8713928,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8635877,
					sizeY = 0.1670757,
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
						varName = "desc",
						posX = 0.5,
						posY = 0.4530917,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9727883,
						sizeY = 0.7895457,
						text = "萃取具体什么意思在这里说明一下吧",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk2",
					posX = 0.5,
					posY = 0.7244661,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8635877,
					sizeY = 0.2660446,
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
						name = "top4",
						posX = 0.5,
						posY = 0.9967328,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4223148,
						sizeY = 0.2484878,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "taz4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7293959,
							sizeY = 0.9861619,
							text = "获得道具",
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
						etype = "Scroll",
						name = "lb2",
						varName = "getScroll",
						posX = 0.5,
						posY = 0.4383737,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9837844,
						sizeY = 0.7924768,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk3",
					posX = 0.5,
					posY = 0.390981,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8635877,
					sizeY = 0.2660446,
					image = "b#d5",
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
						sizeX = 0.4223148,
						sizeY = 0.2484878,
						image = "chu1#top2",
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
						etype = "Scroll",
						name = "lb",
						varName = "costScroll",
						posX = 0.5,
						posY = 0.4383737,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9837844,
						sizeY = 0.7924768,
						horizontal = true,
						showScrollBar = false,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "sj2",
					varName = "extractBtn",
					posX = 0.5,
					posY = 0.1186214,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3101605,
					sizeY = 0.1101814,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ff2",
						varName = "btn_label",
						posX = 0.5,
						posY = 0.5121213,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9625977,
						sizeY = 1.028664,
						text = "萃 取",
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
				posY = 0.861229,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#bgcq",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.6746078,
				posY = 0.8229026,
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
	guang = {
		guang = {
			scale = {{0, {1, 1, 1}}, {300, {4, 0, 1}}, },
			alpha = {{0, {1}}, {300, {0}}, },
		},
	},
	guang2 = {
		guang2 = {
			alpha = {{0, {1}}, {400, {0}}, },
		},
	},
	guang3 = {
		guang3 = {
			alpha = {{0, {1}}, {300, {0}}, },
			scale = {{0, {1,1,1}}, {300, {1, 0, 1}}, },
		},
	},
	guang4 = {
		guang4 = {
			scale = {{0, {1,1,1}}, {100, {1, 0, 1}}, },
			alpha = {{0, {1}}, },
		},
	},
	guang5 = {
		guang5 = {
			alpha = {{0, {0}}, {50, {1}}, {300, {0}}, },
			scale = {},
		},
	},
	guang6 = {
		guang6 = {
			alpha = {{0, {0.5}}, {500, {0}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_jnsj = {
		{0,"guang", 1, 100},
		{2,"lizi2", 1, 100},
		{0,"guang2", 1, 0},
		{0,"guang3", 1, 0},
		{0,"guang4", 1, 0},
		{0,"guang5", 1, 0},
		{0,"guang6", 1, 100},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
