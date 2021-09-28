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
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4335938,
				sizeY = 0.5555556,
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
						posX = 0.6903795,
						posY = 0.7761954,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6656432,
						sizeY = 0.5902329,
						image = "b#d2",
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
							posX = 0.502263,
							posY = 0.5029278,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9666669,
							sizeY = 0.9518004,
							text = "匆忙之间xxxx",
							color = "FF966856",
						},
					},
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "scroll2",
						posX = 0.1375156,
						posY = 0.548513,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4056365,
						sizeY = 1.020581,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "yjzb",
						varName = "yes_btn",
						posX = 0.6903795,
						posY = 0.2861356,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6656432,
						sizeY = 0.1869592,
						image = "qyrw#an",
						imageNormal = "qyrw#an",
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
							color = "FFB37239",
							fontSize = 22,
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
						posX = 0.6903795,
						posY = 0.09650388,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6656432,
						sizeY = 0.1869592,
						image = "qyrw#an",
						imageNormal = "qyrw#an",
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
							color = "FFB37239",
							fontSize = 22,
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
						etype = "Label",
						name = "wb",
						varName = "time",
						posX = 0.6903795,
						posY = 0.4265158,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "剩余时间：xxxx",
						color = "FFC93034",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Sprite3D",
						name = "mx",
						varName = "icon",
						posX = 0.1396282,
						posY = 0.01739329,
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
					posX = 0.9488995,
					posY = 0.9355772,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1171171,
					sizeY = 0.1575,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
