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
				name = "z2",
				posX = 0.5,
				posY = 0.4638885,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9188007,
				sizeY = 0.9355062,
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
					etype = "Image",
					name = "db",
					posX = 0.6220188,
					posY = 0.4905233,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6549055,
					sizeY = 0.8787524,
					image = "tmmgbj#tmmgbj",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.6222518,
					posY = 0.3044193,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6629893,
					sizeY = 0.5276653,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dz1",
						posX = 0.2033258,
						posY = 0.6464754,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.259005,
						sizeY = 0.1636638,
						text = "需求等级：",
						color = "FF939FF8",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz2",
						varName = "need_lv",
						posX = 0.4071313,
						posY = 0.6464752,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4122587,
						sizeY = 0.1636638,
						text = "60",
						color = "FF939FF8",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz3",
						posX = 0.2033258,
						posY = 0.5790716,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.259005,
						sizeY = 0.1636638,
						text = "开启日期：",
						color = "FF939FF8",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz4",
						varName = "open_date",
						posX = 0.4481047,
						posY = 0.5790716,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4942051,
						sizeY = 0.1636638,
						text = "10：00~12：30",
						color = "FF939FF8",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz5",
						posX = 0.2033258,
						posY = 0.5116675,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.259005,
						sizeY = 0.1636638,
						text = "开启时间：",
						color = "FF939FF8",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz6",
						varName = "open_time",
						posX = 0.4071313,
						posY = 0.5116675,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4122587,
						sizeY = 0.1636638,
						text = "5",
						color = "FF939FF8",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "cj",
						varName = "join",
						posX = 0.8341731,
						posY = 0.1703262,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2090498,
						sizeY = 0.1800704,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "asc",
							varName = "join_text",
							posX = 0.5,
							posY = 0.515625,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.003805,
							sizeY = 0.9757967,
							text = "进 入",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF2A6953",
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
						name = "dz9",
						varName = "not_open",
						posX = 0.834173,
						posY = 0.3153586,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6332906,
						sizeY = 0.1636638,
						text = "尚未开启",
						color = "FFFB2642",
						fontSize = 22,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz10",
						varName = "countdown_desc",
						posX = 0.6793676,
						posY = 0.3153586,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3288093,
						sizeY = 0.1636638,
						text = "结束倒计时：",
						color = "FFFB2642",
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz11",
						varName = "countdown",
						posX = 1.013408,
						posY = 0.3153586,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3136994,
						sizeY = 0.1636638,
						text = "10",
						color = "FFFB2642",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
					varName = "reward",
					posX = 0.6218153,
					posY = 0.1591551,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6629893,
					sizeY = 0.216406,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "rewards",
						posX = 0.371655,
						posY = 0.3835743,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6216105,
						sizeY = 0.5488346,
						horizontal = true,
						showScrollBar = false,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "topz",
						posX = 0.2630676,
						posY = 0.7812583,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3771718,
						sizeY = 0.4528939,
						text = "奖励",
						color = "FF939FF8",
						fontOutlineColor = "FFA47848",
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
				etype = "Button",
				name = "an6",
				varName = "helpBtn",
				posX = 0.9346552,
				posY = 0.1131345,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.0875,
				image = "tong#bz",
				imageNormal = "tong#bz",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sm",
				varName = "ExplainBtn",
				posX = 0.8648401,
				posY = 0.760056,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.075,
				sizeY = 0.125,
				image = "shuoming#shuoming",
				imageNormal = "shuoming#shuoming",
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
