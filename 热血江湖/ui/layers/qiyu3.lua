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
				posY = 0.5166668,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.54375,
				sizeY = 0.5402778,
				image = "qiyud#qiyud",
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
						posX = 0.6129543,
						posY = 0.4684953,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6656432,
						sizeY = 0.5902329,
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
							posX = 0.5,
							posY = 0.5930607,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9666669,
							sizeY = 0.9518004,
							text = "匆忙之间xxxx",
							color = "FF966856",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "yjzb",
						varName = "yes_btn",
						posX = 0.8,
						posY = -0.08256045,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2998636,
						sizeY = 0.2014006,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ys2",
							varName = "yes_desc",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9120977,
							sizeY = 1.156784,
							text = "帮他付酒钱",
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
						varName = "no_btn",
						posX = 0.2,
						posY = -0.08256045,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2998636,
						sizeY = 0.2014006,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
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
							sizeX = 0.9120977,
							sizeY = 1.156784,
							text = "就当没看见",
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
				{
					prop = {
						etype = "Sprite3D",
						name = "mx",
						varName = "icon",
						posX = 0.1069374,
						posY = 0.8551838,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3841451,
						sizeY = 0.9865901,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.8255371,
					posY = 0.7815942,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0933908,
					sizeY = 0.1619537,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "qy",
					posX = -0.02643259,
					posY = 0.4846009,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2356322,
					sizeY = 0.7352185,
					image = "qyrw#qiyuan",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "djs",
					varName = "time",
					posX = 0.5941715,
					posY = 0.1945618,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "daojishi",
					color = "FFC93034",
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
