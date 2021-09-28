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
			image = "a",
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
				name = "fj1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.84375,
				sizeY = 0.3611111,
				image = "e#dt",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt2",
					varName = "taskTips3",
					posX = 0.2753684,
					posY = 0.8966804,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3198445,
					sizeY = 0.2,
					image = "g#g_rwd2.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dg",
						posX = 0.6108435,
						posY = 0.403846,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7815612,
						sizeY = 0.7615065,
						image = "w#w_cdd.png",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "top2",
						varName = "taskTips2",
						posX = 0.6531534,
						posY = 0.5247223,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6531309,
						sizeY = 1.186647,
						text = "宗门消息",
						color = "FFE2FF5C",
						fontSize = 26,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "rw",
					posX = 0.1514819,
					posY = 0.6074069,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2009259,
					sizeY = 1.4,
					image = "zm#zm_rw1.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.46875,
				sizeY = 0.4166667,
				image = "a",
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "close_btn",
					posX = 0.2920092,
					posY = 0.2401174,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2283333,
					sizeY = 0.16,
					image = "w#qq4",
					imageNormal = "w#qq4",
					imagePressed = "w#qq2",
					imageDisable = "w#qq1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz1",
						posX = 0.4927007,
						posY = 0.5003267,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313715,
						sizeY = 0.9359564,
						text = "稍 后",
						color = "FFB0FFD9",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF0C604E",
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
					name = "zmmc",
					posX = 0.5308512,
					posY = 0.5466672,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8401453,
					sizeY = 0.3853453,
					text = "宗主大人，我们已经到达您指定的宗门附近，是否可以开始进攻？",
					color = "FFC2F9E8",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					posX = 0.8094934,
					posY = 0.2401174,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2283333,
					sizeY = 0.16,
					image = "w#ee4",
					imageNormal = "w#ee4",
					imagePressed = "w#ee2",
					imageDisable = "w#qq1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						posX = 0.4927007,
						posY = 0.5003267,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313715,
						sizeY = 0.9359564,
						text = "查 看",
						color = "FFF1FFB0",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF69360B",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
