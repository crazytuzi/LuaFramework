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
			sizeX = 0.709375,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cjsl2",
				varName = "CjSl2",
				posX = 0.5134498,
				posY = 0.4194325,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9724669,
				sizeY = 0.9755149,
				image = "jrzfbanner#jrzfbanner",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hdd2",
					posX = 0.9056121,
					posY = 0.1031042,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4884906,
					sizeY = 0.2494332,
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
						name = "smd2",
						posX = 0.3087783,
						posY = 0.8990206,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.705302,
						sizeY = 0.7772736,
						alpha = 0.5,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb4",
							posX = -1.570656,
							posY = 3.464951,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4314432,
							sizeY = 0.7248285,
							text = "活动期限：",
							color = "FF993FFF",
							fontOutlineEnable = true,
							fontOutlineColor = "FFFBFBF3",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb5",
							varName = "ActivitiesTime",
							posX = -0.7143859,
							posY = 3.47646,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.409086,
							sizeY = 0.7248285,
							text = "不限时",
							color = "FF993FFF",
							fontOutlineEnable = true,
							fontOutlineColor = "FFFBFBF3",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb6",
							varName = "ActivitiesContent",
							posX = 0.5199314,
							posY = -0.3400179,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.022459,
							sizeY = 0.7248288,
							text = "活动描述：",
							color = "FFF6C07F",
							fontOutlineColor = "FFFBFBF3",
							fontOutlineSize = 2,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "djk",
							varName = "item_bg",
							posX = 0.5,
							posY = 0.4736085,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.262965,
							sizeY = 0.9210512,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "djt",
								varName = "item_icon",
								posX = 0.496283,
								posY = 0.5204575,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7624841,
								sizeY = 0.7613827,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "suo2",
								varName = "item_suo",
								posX = 0.1846533,
								posY = 0.2284948,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 0.3157895,
								sizeY = 0.3225807,
								image = "tb#suo",
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
		{
			prop = {
				etype = "Scroll",
				name = "lb2",
				varName = "GradeGiftList",
				posX = 0.3411192,
				posY = 0.2956506,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6036347,
				sizeY = 0.6782615,
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
