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
					name = "lbk",
					posX = 0.4999731,
					posY = 0.3086699,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.5864045,
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
						name = "lb",
						varName = "gradeGiftList",
						posX = 0.5,
						posY = 0.4987349,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.9731433,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.5030628,
					posY = 0.8059955,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.029096,
					sizeY = 0.4081633,
					image = "zeng#cb",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz",
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
						posX = 0.690195,
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
							posX = -0.3861738,
							posY = 0.8058305,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4314432,
							sizeY = 0.7248285,
							text = "活动期限：",
							color = "FFFFE5C4",
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
							posX = -0.03795926,
							posY = 0.8058305,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6524516,
							sizeY = 0.7248285,
							text = "不限时",
							color = "FFFFE5C4",
							fontOutlineColor = "FFFDE2FF",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb3",
							varName = "ActivitiesContent",
							posX = -0.09066579,
							posY = 1.123297,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.022459,
							sizeY = 0.7248288,
							text = "活动描述：",
							color = "FFFFEF3B",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF5D131B",
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
					etype = "Label",
					name = "ts",
					varName = "desc",
					posX = 0.7413955,
					posY = 0.6451416,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5140423,
					sizeY = 0.1091211,
					text = "注：赠品直接进入背包",
					color = "FFFFE5C4",
					hTextAlign = 2,
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
