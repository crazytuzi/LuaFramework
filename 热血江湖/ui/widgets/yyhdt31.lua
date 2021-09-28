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
			sizeX = 0.7101563,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "czsl",
				varName = "CZSL",
				posX = 0.5000001,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9988998,
				sizeY = 0.8625783,
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
					name = "hdd2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 1.345503,
					image = "cwlbbanner#cwlbbanner",
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
						name = "smd2",
						posX = 0.4960244,
						posY = 0.6416502,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.004956,
						sizeY = 0.5428975,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb10",
							posX = 0.1496255,
							posY = 0.498616,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2390431,
							sizeY = 0.7248284,
							text = "活动期限：",
							color = "FFF6C07F",
							fontSize = 22,
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
							posX = 0.3354964,
							posY = 0.4970142,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3618317,
							sizeY = 0.2653505,
							text = "3天23小时22分钟",
							color = "FF76D646",
							fontSize = 22,
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
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.9378393,
							sizeY = 0.4034728,
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
						name = "czan3",
						varName = "payBtn",
						posX = 0.8943967,
						posY = 0.6520102,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1354626,
						sizeY = 0.1090226,
						image = "chu1#an4",
						imageNormal = "chu1#an4",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "czz",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8841925,
							sizeY = 0.8307174,
							text = "充 值",
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
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb4",
				varName = "giftList",
				posX = 0.5,
				posY = 0.2663032,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9434446,
				sizeY = 0.6239154,
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
