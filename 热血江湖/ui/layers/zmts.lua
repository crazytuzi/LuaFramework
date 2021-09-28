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
					posX = 0.5,
					posY = 0.2267746,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3694626,
					sizeY = 0.2588936,
					propagateToChildren = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "das",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6180147,
						sizeY = 0.6180145,
						image = "w#w_qq4.png",
						imageNormal = "w#w_qq4.png",
						disableClick = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wz1",
						posX = 0.5,
						posY = 0.5003267,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313715,
						sizeY = 0.9359564,
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
					name = "zmmc",
					varName = "desc_label",
					posX = 0.5308512,
					posY = 0.5466672,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8401453,
					sizeY = 0.3853453,
					text = "您的新宗门得到了附近村民的关注，不少身怀武艺的村民纷纷表示要加入宗门。",
					color = "FFC2F9E8",
					fontSize = 24,
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
