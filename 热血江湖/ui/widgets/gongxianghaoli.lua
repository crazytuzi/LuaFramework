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
					posX = 0.507229,
					posY = 0.3480785,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.025178,
					sizeY = 0.6886953,
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
						varName = "SharedGiftList",
						posX = 0.4959361,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9993407,
						sizeY = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hdd",
					posX = 0.5030628,
					posY = 0.8535354,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.024502,
					sizeY = 0.3222187,
					image = "gongxiang#top",
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
							posX = 1.413116,
							posY = 0.3472247,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8721342,
							sizeY = 0.7248285,
							text = "活动期限：",
							color = "FFA034FE",
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
							posX = 1.869969,
							posY = 0.3472258,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8843795,
							sizeY = 0.7248285,
							text = "800分钟",
							color = "FFA034FE",
							fontOutlineEnable = true,
							fontOutlineColor = "FFFDE2FF",
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
						varName = "ActivitiesContent",
						posX = 0.745258,
						posY = 0.5203216,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4785897,
						sizeY = 0.4061179,
						text = "描述文字",
						fontOutlineEnable = true,
						fontOutlineColor = "FF752F8C",
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
