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
				name = "czsl",
				varName = "CZSL",
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
					posX = 0.5030629,
					posY = 0.7913808,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.019908,
					sizeY = 0.4491055,
					image = "huiguidenglu#huiguidenglu",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.6773024,
						posY = 0.7357919,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6183231,
						sizeY = 0.4972313,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb10",
							posX = 0.05370051,
							posY = -0.4405935,
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
							name = "wb11",
							varName = "ActivitiesTime",
							posX = 0.4625084,
							posY = -0.4405935,
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
							name = "wb12",
							varName = "ActivitiesContent",
							posX = 0.3711449,
							posY = 0.340933,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.9809483,
							sizeY = 0.7416581,
							text = "收集合成特定道具即可兑换精美道具",
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
				{
					prop = {
						etype = "Label",
						name = "wb13",
						varName = "ActivitiesTitle",
						posX = 0.5251141,
						posY = 0.2159147,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3955753,
						sizeY = 0.4061177,
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF00335D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "lbk4",
					posX = 0.4999731,
					posY = 0.2909168,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.5743719,
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
						name = "lb4",
						varName = "ExchangeGiftList",
						posX = 0.5,
						posY = 0.4995568,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.9664534,
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
