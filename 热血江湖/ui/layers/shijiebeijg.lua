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
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.755045,
					sizeY = 0.7036449,
					image = "sjbbj4#sjbbj4",
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "sm2",
					varName = "des",
					posX = 0.5,
					posY = 0.3095898,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.405349,
					sizeY = 0.1879639,
					text = "您消耗xxxx绑定元宝，竞猜巴西队止步小组赛",
					color = "FFFFEF81",
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
					posY = 0.8061203,
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
					etype = "Grid",
					name = "jd2",
					posX = 0.5,
					posY = 0.5386481,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.489261,
					sizeY = 0.1635637,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wb3",
						varName = "rank",
						posX = 0.3473959,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6114753,
						sizeY = 0.8952684,
						text = "获得第三名",
						color = "FFB1EEF8",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF011D32",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb4",
						varName = "date",
						posX = 0.605324,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5703943,
						sizeY = 0.9874705,
						text = "开奖日期：xxxxxxx",
						color = "FFFFDF30",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tb3",
						posX = 0.7730154,
						posY = 0.5116103,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.07265519,
						sizeY = 0.5813463,
						image = "tb#yuanbao",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo3",
							posX = 0.6398034,
							posY = 0.3202246,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5599998,
							sizeY = 0.56,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "slz3",
							varName = "coin",
							posX = 2.596299,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.955618,
							sizeY = 1.324514,
							text = "x5000",
							color = "FFFFDF30",
							fontSize = 22,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "sm3",
					varName = "des2",
					posX = 0.5,
					posY = 0.2202086,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.318929,
					sizeY = 0.1879639,
					text = "提示第二句",
					color = "FFFFEF81",
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
				varName = "close",
				posX = 0.8333054,
				posY = 0.7218924,
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
