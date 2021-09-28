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
					lockHV = true,
					sizeX = 1.019908,
					sizeY = 1.027438,
					image = "huiguishuangbei#huiguishuangbei",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.768257,
						posY = 0.1813895,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6182364,
						sizeY = 0.2111007,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb10",
							varName = "title",
							posX = 0.183526,
							posY = 0.6777321,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4314432,
							sizeY = 1.02058,
							text = "活动期限：",
							color = "FF5E006F",
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
							posX = 0.5900127,
							posY = 0.6777329,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6296438,
							sizeY = 1.02058,
							text = "3天23小时22分钟",
							color = "FF5E006F",
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
					posY = 0.1388986,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9739665,
					sizeY = 0.3374056,
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
						varName = "content",
						posX = 0.7148821,
						posY = 0.2762971,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5748332,
						sizeY = 0.6055309,
						text = "普通副本、组队副本掉落翻倍普通副本、组队副本掉落翻倍",
						color = "FF43261D",
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFFFFF",
						fontOutlineSize = 2,
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
