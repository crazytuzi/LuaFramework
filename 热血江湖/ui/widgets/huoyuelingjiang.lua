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
					name = "lbk4",
					posX = 0.4999731,
					posY = 0.2835588,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.5596559,
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
						varName = "scheduleGiftList",
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
					name = "hdd",
					posX = 0.5,
					posY = 0.7900762,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.00905,
					sizeY = 0.4555792,
					image = "huoyuelingjiang#huoyuelingjiang",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.3300001,
						posY = 0.2333583,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3688571,
						sizeY = 0.4963446,
						image = "d#sld3",
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb10",
							posX = 0.7878171,
							posY = 0.464388,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8721342,
							sizeY = 0.7248285,
							text = "活动时间：",
							color = "FFF9E957",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF5A0E04",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb11",
							varName = "ActivitiesTime",
							posX = 1.604867,
							posY = 0.464388,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.325511,
							sizeY = 0.7248285,
							text = "800分钟",
							color = "FFF9E957",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF5A0E04",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb12",
							posX = 0.7878171,
							posY = 0.7544568,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8721342,
							sizeY = 0.7248285,
							text = "累计活跃度：",
							color = "FFF9E957",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF5A0E04",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb13",
							varName = "activePoint",
							posX = 1.204373,
							posY = 0.7544568,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5245228,
							sizeY = 0.7248285,
							text = "800",
							color = "FFF9E957",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF5A0E04",
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
