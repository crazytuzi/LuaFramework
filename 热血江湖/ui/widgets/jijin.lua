--version = 1
local l_fileType = "node"

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
			etype = "Grid",
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jijin",
				varName = "JiJin",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.5030628,
					posY = 0.856932,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.024502,
					sizeY = 0.315426,
					image = "touzijijin#touzijijin",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz3",
						varName = "ActivitiesTitle",
						posX = 0.8516334,
						posY = 0.2412578,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.2877358,
						sizeY = 0.4071879,
						fontSize = 26,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.3669042,
						posY = 0.03116572,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6183231,
						sizeY = 0.5428975,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb7",
							posX = 0.1540563,
							posY = 0.7358281,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4314432,
							sizeY = 0.7248285,
							text = "活动期限：",
							color = "FF5E006F",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFFDE2FF",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb8",
							varName = "ActivitiesTime",
							posX = 0.5666401,
							posY = 0.7358281,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6524516,
							sizeY = 0.7248285,
							text = "3天23小时22分钟",
							color = "FF5E006F",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFFDE2FF",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb9",
							varName = "ActivitiesContent",
							posX = 0.4072553,
							posY = 0.2956728,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.9378392,
							sizeY = 0.7416577,
							text = "基金购买后永久有效！",
							color = "FFFFFD5E",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFCE151F",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbk3",
					posX = 0.4999731,
					posY = 0.3197812,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.6321007,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb3",
						varName = "fundGiftList",
						posX = 0.5,
						posY = 0.5022127,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.9661876,
						showScrollBar = false,
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "lq",
				varName = "BuyBtn",
				posX = 0.8400214,
				posY = 0.6732229,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1990812,
				sizeY = 0.1156463,
				image = "chu1#an4",
				imageNormal = "chu1#an4",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "lqz",
					varName = "BuyBtnText",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8247252,
					sizeY = 1.143941,
					text = "投 资",
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
				etype = "RichText",
				name = "bt",
				varName = "BuyContent",
				posX = 0.3475558,
				posY = 0.6732228,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6732999,
				sizeY = 0.1088435,
				text = "升到预定等级，领取奖励基金",
				color = "FF43261D",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
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
