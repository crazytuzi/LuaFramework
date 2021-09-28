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
					posX = 0.4939245,
					posY = 0.8124106,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.042779,
					sizeY = 0.493519,
					image = "chongzhisongli#chongzhisongli",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz4",
						varName = "ActivitiesTitle",
						posX = 0.8617375,
						posY = 0.2627854,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.190116,
						sizeY = 0.3713244,
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
						posX = 0.6773024,
						posY = 0.7129585,
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
							name = "wb10",
							posX = -0.01128561,
							posY = -0.4312294,
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
							posX = 0.3899962,
							posY = -0.4312297,
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
							posX = 0.2539114,
							posY = -0.007868286,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9378392,
							sizeY = 0.7416577,
							text = "达到元宝消费数量即可领取奖励达到元宝消费数量即可领取奖励",
							color = "FFF4FAFF",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF4663C3",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "czan",
						varName = "payBtn",
						posX = 0.9031933,
						posY = 0.2522914,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1806341,
						sizeY = 0.2664928,
						image = "chu1#an4",
						imageNormal = "chu1#an4",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "czz",
							posX = 0.5,
							posY = 0.5344828,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8841925,
							sizeY = 0.8307174,
							text = "储 值",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
							fontOutlineSize = 2,
							hTextAlign = 1,
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
					name = "lbk4",
					posX = 0.4999731,
					posY = 0.3152526,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.6230435,
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
