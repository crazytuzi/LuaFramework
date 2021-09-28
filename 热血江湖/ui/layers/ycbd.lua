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
				varName = "imgBK",
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
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4261363,
				sizeY = 0.3543084,
				image = "g#d3",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.1568548,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.98125,
					sizeY = 0.308,
					image = "d#sld4",
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "desc",
					posX = 0.5124797,
					posY = 0.7890378,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7711704,
					sizeY = 0.4022819,
					text = "是否要隐藏全部进攻和防守部队（200元宝/7天）",
					color = "FF95FE5C",
					fontSize = 22,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel",
					posX = 0.2484894,
					posY = 0.1570169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2854167,
					sizeY = 0.192,
					image = "w#w_qq4.png",
					imageNormal = "w#w_qq4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						varName = "no_name",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.7566052,
						text = "取 消",
						color = "FFB0FFD9",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF145A4F",
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
					varName = "ok",
					posX = 0.7540076,
					posY = 0.1570169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2854167,
					sizeY = 0.192,
					image = "w#w_ee4.png",
					imageNormal = "w#w_ee4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						varName = "yes_name",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.7566052,
						text = "确 定",
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
					etype = "Label",
					name = "ts2",
					posX = 0.5,
					posY = 0.4796518,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8369418,
					sizeY = 0.3538306,
					text = "预设隐藏一只部队，全部隐藏后其他玩家无法看见你的阵容",
					color = "FF28F7FF",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF06100F",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
