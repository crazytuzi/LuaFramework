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
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				alpha = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.5022541,
					posY = 0.4977324,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.019908,
					sizeY = 1.027438,
					image = "ewaidiaoluo#ewaidiaoluo",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.6773024,
						posY = 0.8520123,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6183231,
						sizeY = 0.2647895,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb10",
							posX = -0.2595425,
							posY = -0.335312,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.39753,
							sizeY = 0.337604,
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
							posX = 0.3863467,
							posY = -0.3353122,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.053332,
							sizeY = 0.337604,
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
							name = "wb13",
							varName = "ActivitiesTitle",
							posX = 0.3320966,
							posY = -0.4876069,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.476552,
							sizeY = 0.6565704,
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF00335D",
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
					posX = 0.5,
					posY = 0.5271657,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9739665,
					sizeY = 0.2988309,
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "wb12",
						varName = "ActivitiesContent",
						posX = 0.6060201,
						posY = 0.16741,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.645166,
						sizeY = 1.108048,
						text = "通过什么什么副本，有几率获得额外掉落物品。",
						color = "FF43261D",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFFFFF",
						fontOutlineSize = 2,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "js",
						posX = 0.2104128,
						posY = 0.5987998,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2434872,
						sizeY = 0.3036204,
						text = "活动介绍：",
						color = "FF43261D",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFFFFF",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb4",
					varName = "ExtraDropList",
					posX = 0.5,
					posY = 0.1015614,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9188361,
					sizeY = 0.2218574,
					horizontal = true,
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
