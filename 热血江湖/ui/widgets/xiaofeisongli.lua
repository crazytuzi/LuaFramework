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
				name = "xfsl",
				varName = "XfSl",
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
					name = "lbk2",
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
						name = "lb2",
						varName = "giftList",
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
			{
				prop = {
					etype = "Image",
					name = "hhd",
					posX = 0.5030628,
					posY = 0.8218417,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.024502,
					sizeY = 0.3856062,
					image = "xiaofeisongli#xiaofeisongli",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz2",
						varName = "ActivitiesTitle",
						posX = 0.8429004,
						posY = 0.295129,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.2968585,
						sizeY = 0.4914356,
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
						posX = 0.6583272,
						posY = 0.1909857,
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
							name = "wb4",
							posX = 0.06084996,
							posY = 0.3276332,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4314432,
							sizeY = 0.5374154,
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
							name = "wb5",
							varName = "ActivitiesTime",
							posX = 0.4735653,
							posY = 0.3276337,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6524516,
							sizeY = 0.5374154,
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
							name = "wb6",
							varName = "ActivitiesContent",
							posX = 0.3864769,
							posY = 0.3115645,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.9378392,
							sizeY = 0.5374154,
							text = "达到元宝消费数量即可领取奖励",
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
