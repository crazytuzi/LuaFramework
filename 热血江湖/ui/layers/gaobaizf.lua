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
			sizeX = 0.6,
			sizeY = 0.6,
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
				sizeX = 0.75,
				sizeY = 0.8,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					varName = "background",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.105903,
					sizeY = 1.481481,
					image = "gaobai#bj",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.5173319,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8644516,
					sizeY = 0.5315333,
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
						name = "wbz",
						varName = "label",
						posX = 0.498001,
						posY = 0.6164694,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7578927,
						sizeY = 0.6785923,
						text = "告白宣言",
						color = "FFCB4940",
						fontSize = 22,
						lineSpace = 15,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dx",
						posX = 0.4071218,
						posY = 1.076075,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.6147904,
						sizeY = 0.4456536,
						text = "告白对象名称：",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dx2",
						varName = "toRoleName",
						posX = 0.5,
						posY = 1.092407,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.443115,
						sizeY = 0.4456536,
						text = "xxxxxxxx",
						color = "FFA34CE6",
						fontSize = 24,
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
					varName = "sure_btn",
					posX = 0.5,
					posY = 0.09129673,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2746212,
					sizeY = 0.1736111,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "sureText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.048375,
						sizeY = 1.203417,
						text = "祝 福",
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
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.8917274,
					posY = 0.967981,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1006944,
					sizeY = 0.162037,
					image = "gaobai#gb",
					imageNormal = "gaobai#gb",
					disablePressScale = true,
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
