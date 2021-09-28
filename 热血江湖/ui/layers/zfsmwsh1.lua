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
				posX = 0.5023392,
				posY = 0.5506113,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3179688,
				sizeY = 0.6708333,
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
					etype = "Grid",
					name = "mw",
					posX = 0.5,
					posY = 0.7529455,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8143874,
					sizeY = 0.3053442,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "aa",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.021935,
						sizeY = 1.009911,
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
							name = "top",
							posX = 0.5,
							posY = 0.9942215,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5491161,
							sizeY = 0.2417033,
							image = "chu1#top2",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "top1",
								posX = 0.5,
								posY = 0.5552834,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6,
								sizeY = 0.8874494,
								text = "回收",
								color = "FF966856",
								fontSize = 24,
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
						name = "bb3",
						posX = 0.2096239,
						posY = 0.4519324,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2835975,
						sizeY = 0.6373692,
						image = "djk#kzi",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "b3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8229166,
							sizeY = 0.8125,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "dj",
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
						etype = "Label",
						name = "cc3",
						posX = 0.575864,
						posY = 0.5792859,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4187822,
						sizeY = 0.2379453,
						text = "者·水密文",
						color = "FFFF7E2D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "cc4",
						posX = 0.5670288,
						posY = 0.3715275,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4011115,
						sizeY = 0.2565501,
						text = "（3级）",
						color = "FFFF7E2D",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.3608011,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8143874,
					sizeY = 0.3053442,
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
						name = "top2",
						posX = 0.5,
						posY = 0.9942215,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5611609,
						sizeY = 0.2440989,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "top3",
							posX = 0.5,
							posY = 0.5552834,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.8874494,
							text = "获得",
							color = "FF966856",
							fontSize = 24,
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
						posX = 0.5,
						posY = 0.4408529,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9487956,
						sizeY = 0.8044489,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel_btn",
					posX = 0.2438295,
					posY = 0.1006297,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3444383,
					sizeY = 0.1273767,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						varName = "no_name",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422305,
						text = "取 消",
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
					etype = "Button",
					name = "a2",
					varName = "ok_btn",
					posX = 0.7472644,
					posY = 0.1006297,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3444383,
					sizeY = 0.1273767,
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
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422306,
						text = "回收",
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
					etype = "Image",
					name = "gb",
					posX = 0.9486964,
					posY = 0.9445509,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1597051,
					sizeY = 0.1304348,
					image = "baishi#x",
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
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
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
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
