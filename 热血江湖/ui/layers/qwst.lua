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
						varName = "title_desc",
						posX = 0.6531534,
						posY = 0.5247223,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6531309,
						sizeY = 1.186647,
						text = "前往收徒",
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
					etype = "RichText",
					name = "zmmc",
					varName = "desc",
					posX = 0.536513,
					posY = 0.5037884,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5259878,
					sizeY = 0.4070203,
					text = "宗主大人，我这就去宣讲我宗的神威，争取收到大量优秀弟子。",
					color = "FFC2F9E8",
					fontSize = 22,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "sure_btn",
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
						name = "wz1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313715,
						sizeY = 0.9355705,
						text = "确 定",
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
					name = "z1",
					varName = "time_desc",
					posX = 0.4592604,
					posY = 0.3914862,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3723604,
					sizeY = 0.1744517,
					text = "预计完成时间10分钟",
					color = "FF5DD13D",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
