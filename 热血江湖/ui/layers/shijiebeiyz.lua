--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "PKLayer",
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
				varName = "PKPanel",
				posX = 0.5007802,
				posY = 0.5013853,
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
			sizeX = 0.88,
			sizeY = 0.98,
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
				sizeX = 0.4102418,
				sizeY = 0.7452287,
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
					posX = 0.5,
					posY = 0.4543585,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.755045,
					sizeY = 1.146751,
					image = "sjbbj3#sjbbj3",
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
						name = "dk",
						posX = 0.4992761,
						posY = 0.5615699,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9222561,
						sizeY = 0.6528192,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "content",
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
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "sm2",
					varName = "des",
					posX = 0.5,
					posY = 0.06807135,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.37294,
					sizeY = 0.1879639,
					text = "竞猜名次无法相容，比如竞猜止步8强后，队伍获得第4名，无法得奖。\n若开奖时未胜利将返还绑元",
					color = "FF5AEF00",
					fontOutlineEnable = true,
					fontOutlineColor = "FF054B5B",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "yzz",
					varName = "country",
					posX = 0.5,
					posY = 0.9831837,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.974074,
					sizeY = 0.153479,
					text = "对中国队进行竞猜",
					fontSize = 26,
					fontOutlineEnable = true,
					fontOutlineColor = "FF451B0E",
					hTextAlign = 1,
					vTextAlign = 1,
					colorTL = "FFFEFCBF",
					colorTR = "FFFEFCBF",
					colorBR = "FFEBB240",
					colorBL = "FFEBB240",
					useQuadColor = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "yzan",
					posX = 0.5,
					posY = -0.05436174,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2943109,
					sizeY = 0.1083994,
					image = "shijiebei#an",
					imageNormal = "shijiebei#an",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "yzanz",
						varName = "wagerBtn",
						posX = 0.5,
						posY = 0.5877194,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9736853,
						sizeY = 1.157777,
						text = "竞 猜",
						color = "FF7F2907",
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
					etype = "Image",
					name = "yb",
					posX = 0.7398134,
					posY = -0.04297266,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1082025,
					sizeY = 0.09508716,
					image = "tb#yuanbao",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						posX = 0.6397755,
						posY = 0.4001674,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5400001,
						sizeY = 0.54,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "slz",
						varName = "coin",
						posX = 2.576669,
						posY = 0.4999998,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 2.940001,
						sizeY = 1.32,
						text = "x300",
						color = "FFFFDF30",
						fontOutlineColor = "FFFFFFFF",
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
				posX = 0.8324141,
				posY = 0.8495264,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0443892,
				sizeY = 0.07227891,
				image = "shijiebei#gb",
				imageNormal = "shijiebei#gb",
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
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
