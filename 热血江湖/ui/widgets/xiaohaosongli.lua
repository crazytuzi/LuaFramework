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
					posY = 0.3890693,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.010666,
					sizeY = 0.7606549,
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
						varName = "GradeGiftList",
						posX = 0.5,
						posY = 0.4957538,
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
					posY = 0.8897578,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.029096,
					sizeY = 0.2494331,
					image = "zeng#kk",
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
							posX = -0.09061893,
							posY = 0.8557659,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4314432,
							sizeY = 0.7248285,
							text = "活动期限：",
							color = "FFFFE5C4",
							fontOutlineEnable = true,
							fontOutlineColor = "FF7E1004",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb2",
							varName = "ActivitiesTime",
							posX = 0.2888792,
							posY = 0.8557659,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6524516,
							sizeY = 0.7248285,
							text = "不限时",
							color = "FFFFE5C4",
							fontOutlineEnable = true,
							fontOutlineColor = "FF7E1004",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wb3",
							varName = "ActivitiesContent",
							posX = 0.204889,
							posY = 1.292223,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.022459,
							sizeY = 0.7248288,
							text = "活动描述：",
							color = "FFFFF150",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF7E1004",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "djk",
							varName = "item_bg",
							posX = -0.4678072,
							posY = 1.44039,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2262264,
							sizeY = 1.574046,
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
