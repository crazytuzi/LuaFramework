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
				varName = "close_btn",
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
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5008878,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5539773,
				sizeY = 0.4861111,
				image = "xinchundenglong#dengjuan",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "time",
					posX = 0.5175991,
					posY = 0.6479142,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238425,
					sizeY = 0.2755472,
					text = "好礼不停，敬请期待。",
					color = "FFFFEADC",
					fontSize = 22,
					fontOutlineColor = "FFE1EDA5",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "btn",
					posX = 0.5175992,
					posY = 0.2766726,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.301282,
					sizeY = 0.1778426,
					image = "xinchundenglong#qianwang",
					imageNormal = "xinchundenglong#qianwang",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						posX = 0.5011973,
						posY = 0.5491802,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.9422305,
						text = "前 往",
						color = "FF710F08",
						fontSize = 24,
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
					etype = "Label",
					name = "sj",
					posX = 0.5175991,
					posY = 0.7960706,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8802951,
					sizeY = 0.2755472,
					text = "活动时间",
					color = "FFFFF262",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sj2",
					varName = "activityInfo",
					posX = 0.5175991,
					posY = 0.4697032,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5855121,
					sizeY = 0.2755472,
					text = "活动介绍描述活动介绍描述活动介绍描述活动介绍描述",
					color = "FFFFE270",
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
