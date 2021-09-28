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
				posX = 0.4687513,
				posY = 0.5166668,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7765625,
				sizeY = 0.8111111,
				image = "zlqjbj1#zlqjbj1",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.2,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "pt3",
					posX = 0.5,
					posY = 0.4486107,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8337122,
					sizeY = 0.8424296,
					scale9 = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "db5",
						posX = 0.5457229,
						posY = 0.6086475,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6628247,
						sizeY = 0.436294,
						image = "zlqj#di1",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.44,
						scale9Bottom = 0.45,
					},
					children = {
					{
						prop = {
							etype = "RichText",
							name = "sfw",
							varName = "desc",
							posX = 0.5000001,
							posY = 0.4934469,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9666668,
							sizeY = 0.9386942,
							text = "匆忙之间xxxx",
							color = "FFC2E6FE",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xh1",
							posX = 0.6893855,
							posY = -0.7289485,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.3090403,
							text = "消耗棋力：",
							color = "FFF4D376",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xh2",
							varName = "need_chess",
							posX = 0.8597009,
							posY = -0.7289485,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.3090403,
							text = "500",
							color = "FFF4D376",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xh3",
							posX = 0.7624307,
							posY = -0.7289484,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3136282,
							sizeY = 0.3090403,
							text = "成功率：",
							color = "FFC8F268",
							fontSize = 18,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xh4",
							varName = "success_rate",
							posX = 0.8172725,
							posY = -0.7289484,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3833262,
							sizeY = 0.3090403,
							text = "10%",
							color = "FFC8F268",
							fontSize = 18,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "xh5",
							varName = "left_time",
							posX = 0.2443559,
							posY = -0.7289485,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4898752,
							sizeY = 0.3090403,
							text = "再尝试x次必定成功",
							color = "FFC8F268",
							fontSize = 18,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "plcs",
						varName = "think_btn",
						posX = 0.9312908,
						posY = 0.1619726,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1846243,
						sizeY = 0.2784672,
						image = "zlqj#sikao",
						imageNormal = "zlqj#sikao",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "range",
						varName = "range",
						posX = 0.231424,
						posY = 0.2988799,
						anchorX = 0,
						anchorY = 0.5,
						sizeX = 0.6324764,
						sizeY = 0.1455057,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "state1",
							varName = "state1",
							posX = 0,
							posY = 0.5,
							anchorX = 0,
							anchorY = 0.5,
							sizeX = 0.1,
							sizeY = 1,
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "state2",
							varName = "state2",
							posX = 0,
							posY = 0.5,
							anchorX = 0,
							anchorY = 0.5,
							sizeX = 0.1,
							sizeY = 1,
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "state3",
							varName = "state3",
							posX = 0,
							posY = 0.5,
							anchorX = 0,
							anchorY = 0.5,
							sizeX = 0.1,
							sizeY = 1,
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "state4",
							varName = "state4",
							posX = 0,
							posY = 0.5,
							anchorX = 0,
							anchorY = 0.5,
							sizeX = 0.1,
							sizeY = 1,
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "state5",
							varName = "state5",
							posX = 0,
							posY = 0.5,
							anchorX = 0,
							anchorY = 0.5,
							sizeX = 0.1,
							sizeY = 1,
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "wk",
						posX = 0.5490136,
						posY = 0.2888867,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6866093,
						sizeY = 0.05894562,
						image = "zlqj#tiao",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jt",
						varName = "jiantouview",
						posX = 0.5493284,
						posY = 0.2544236,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.03499415,
						sizeY = 0.08333691,
						image = "zlqj#jt",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.925976,
					posY = 0.8157855,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07444668,
					sizeY = 0.125,
					image = "zlqj#gb",
					imageNormal = "zlqj#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.541177,
					posY = 0.8675539,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3219316,
					sizeY = 0.239726,
					image = "zlqj#zlqj",
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
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
