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
				sizeX = 0.7082108,
				sizeY = 0.6433858,
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
					sizeY = 1.023426,
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
						name = "d2",
						posX = 0.5,
						posY = 0.58777,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9203732,
						sizeY = 0.6767302,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "bt",
							posX = 0.5,
							posY = 0.1621374,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.009354,
							sizeY = 0.2807153,
							image = "d#bt",
							alpha = 0.5,
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
					posX = 0.2524717,
					posY = 0.692077,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4245713,
					sizeY = 0.3583473,
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
						varName = "scroll1",
						posX = 0.5129911,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1.228461,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jdmc2",
					varName = "desc",
					posX = 0.5,
					posY = 0.04772697,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9823301,
					sizeY = 0.1836469,
					text = "随机获得对三个职业的伤害提升或者减免百分之10",
					color = "FF966856",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk3",
					posX = 0.7414584,
					posY = 0.692077,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4245713,
					sizeY = 0.3583473,
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
						name = "lb2",
						varName = "scroll2",
						posX = 0.5129911,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1.228461,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.4944845,
					posY = 0.6832282,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09707561,
					sizeY = 0.1640626,
					image = "sui#jt",
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "xh",
					varName = "scroll3",
					posX = 0.495595,
					posY = 0.3555596,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.847356,
					sizeY = 0.1899672,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "yjzb",
					varName = "saveBtn",
					posX = 0.25,
					posY = 0.1538584,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1599542,
					sizeY = 0.1187295,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ys2",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9120977,
						sizeY = 1.156784,
						text = "保 存",
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
					name = "plcs",
					varName = "practiceBtn",
					posX = 0.75,
					posY = 0.1538584,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1599542,
					sizeY = 0.1187295,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ys3",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9120977,
						sizeY = 1.156784,
						text = "随 机",
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
				name = "top",
				posX = 0.5,
				posY = 0.8279989,
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
					varName = "title_desc",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3181818,
					sizeY = 0.4423076,
					image = "biaoti#zhuxing",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.8329712,
				posY = 0.7826991,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
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
