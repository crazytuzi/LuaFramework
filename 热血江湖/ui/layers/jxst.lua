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
			image = "4",
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
				scale9 = true,
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
						varName = "title_label",
						posX = 0.6531534,
						posY = 0.5247223,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6531309,
						sizeY = 1.186647,
						text = "收徒进行时",
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
			{
				prop = {
					etype = "Label",
					name = "zmmc",
					varName = "desc",
					posX = 0.536513,
					posY = 0.5037884,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5259878,
					sizeY = 0.4070203,
					text = "宗主大人，我正在各村之间奔波，您有什么事情么？",
					color = "FFC2F9E8",
					fontSize = 22,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "time_desc",
					posX = 0.4592604,
					posY = 0.3914862,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3723604,
					sizeY = 0.1744517,
					text = "剩余完成时间：9分30秒",
					color = "FF5DD13D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb1",
					posX = 0.561512,
					posY = 0.20045,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.05817057,
					sizeY = 0.2416316,
					image = "tb#yuanbao",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "suo",
						posX = 0.643078,
						posY = 0.3092576,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4775229,
						sizeY = 0.4775229,
						image = "tb#suo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "money_count",
					posX = 0.6397634,
					posY = 0.1855672,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09188251,
					sizeY = 0.1432765,
					text = "20",
					fontSize = 22,
					fontOutlineEnable = true,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "speedup_btn",
					posX = 0.4691753,
					posY = 0.1918616,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1268518,
					sizeY = 0.1846154,
					image = "w#w_ee4.png",
					imageNormal = "w#w_ee4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz1",
						varName = "speed_label",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8991553,
						sizeY = 1.101974,
						text = "加速招募",
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
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "leave_btn",
					posX = 0.7991861,
					posY = 0.1918615,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1268519,
					sizeY = 0.1846154,
					image = "w#w_qq4.png",
					imageNormal = "w#w_qq4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.001197,
						sizeY = 0.9355705,
						text = "离 开",
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
