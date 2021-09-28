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
				name = "cjsl",
				varName = "CjSl",
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
					varName = "ActivitiesBanner",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.030628,
					sizeY = 1.031746,
					image = "czfyb#czfyb",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.5,
						posY = -0.06012669,
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
							name = "wb1",
							varName = "timeLabel",
							posX = -0.0006847307,
							posY = 1.761288,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.4314433,
							sizeY = 0.394437,
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
							name = "wb2",
							varName = "ActivitiesTime",
							posX = 0.2912529,
							posY = 1.781378,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.065261,
							sizeY = 0.2163717,
							text = "不限时",
							color = "FF5E006F",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFFDE2FF",
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
					name = "lbk",
					posX = 0.4999731,
					posY = 0.3005372,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.5981414,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "gz",
						varName = "des",
						posX = 0.5000002,
						posY = 0.7349241,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9348767,
						sizeY = 0.5144557,
						text = "规则写这里可变色",
						color = "FFD65F25",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
					varName = "payRoot",
					posX = 0.5,
					posY = 0.1444159,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.012458,
					sizeY = 0.1815965,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "czan",
						varName = "buyBtn",
						posX = 0.8103611,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2631837,
						sizeY = 0.8241341,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "czanz",
							posX = 0.5,
							posY = 0.53125,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8818638,
							sizeY = 0.9049659,
							text = "储 值",
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
						name = "gz2",
						varName = "des2",
						posX = 0.5167764,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.933222,
						sizeY = 0.6023465,
						text = "当前已储值0USD",
						color = "FFDE2917",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd2",
					varName = "rewardRoot",
					posX = 0.5,
					posY = 0.1444159,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.012458,
					sizeY = 0.1815965,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "czan2",
						varName = "buyBtn2",
						posX = 0.8103611,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2631837,
						sizeY = 0.8241341,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "czanz2",
							varName = "rewardLabel",
							posX = 0.5,
							posY = 0.53125,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8818638,
							sizeY = 0.9049659,
							text = "领 取",
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
						name = "gz3",
						varName = "des3",
						posX = 0.5167764,
						posY = 0.0379848,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.933222,
						sizeY = 0.6023465,
						text = "还能再领取xxxx绑元",
						color = "FFDE2917",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.3526008,
						posY = 0.719033,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6109082,
						sizeY = 1.009778,
						horizontal = true,
						showScrollBar = false,
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
