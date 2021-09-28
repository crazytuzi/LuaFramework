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
					},
				},
				{
					prop = {
						etype = "Button",
						name = "plcs",
						varName = "accept_btn",
						posX = 0.5457785,
						posY = 0.25734,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2123783,
						sizeY = 0.1280543,
						image = "zlqj#an",
						imageNormal = "zlqj#an",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ys3",
							varName = "no_desc",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.374073,
							sizeY = 1.156784,
							text = "开启棋局",
							color = "FF613623",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFF5D781",
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
