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
			sizeX = 1,
			sizeY = 1,
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
					name = "smd",
					posX = 0.5,
					posY = 0.1568548,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.98125,
					sizeY = 0.308,
					image = "d#sld4",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.6193453,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8865404,
					sizeY = 0.6300896,
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
						name = "ic1",
						varName = "item_icon",
						posX = 0.3264056,
						posY = 0.5824897,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.113738,
						sizeY = 0.3421736,
						image = "tb#tongqian",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "sl1",
							varName = "item_count",
							posX = 2.67117,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.513015,
							sizeY = 0.7825699,
							text = "x123564",
							color = "FFFEDB45",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF00152E",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo",
							varName = "money_suo_icon",
							posX = 0.7178999,
							posY = 0.2821007,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.5454545,
							sizeY = 0.5454544,
							image = "tb#suo",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ic2",
						varName = "ingot_icon",
						posX = 0.3264056,
						posY = 0.2236637,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.113738,
						sizeY = 0.3421736,
						image = "tb#tb_yuanbao1.png",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "sl2",
							varName = "ingot_count",
							posX = 2.671169,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.513015,
							sizeY = 0.7825699,
							text = "x123564",
							color = "FFFEDB45",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF00152E",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo2",
							posX = 0.7178999,
							posY = 0.2821007,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.5454545,
							sizeY = 0.5454544,
							image = "tb#suo",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wz1",
						posX = 0.3392729,
						posY = 0.8511273,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.3651195,
						text = "开采收益：",
						color = "FFC2F9E8",
						fontSize = 24,
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "ok_btn",
					posX = 0.5,
					posY = 0.1570169,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2511667,
					sizeY = 0.18816,
					image = "w#w_qq4.png",
					imageNormal = "w#w_qq4.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8313926,
						sizeY = 0.7566052,
						text = "确 定",
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
