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
			etype = "Image",
			name = "shuxing",
			varName = "attributeRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2882813,
			sizeY = 0.8388889,
			scale9 = true,
			scale9Top = 0.3,
			scale9Bottom = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bb3",
				posX = 0.5,
				posY = 0.5628103,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8536584,
				sizeY = 0.4661208,
				image = "b#d2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zsx3",
					posX = 0.5,
					posY = 0.9984288,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5904762,
					sizeY = 0.1278695,
					image = "chu1#top2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "topz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7508638,
						sizeY = 1.111471,
						text = "喂养属性",
						color = "FFF1E9D7",
						fontOutlineEnable = true,
						fontOutlineColor = "FFA47848",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb3",
					varName = "attribute_scroll",
					posX = 0.4992842,
					posY = 0.465966,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9823722,
					sizeY = 0.8995705,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "qmd2",
				posX = 0.5,
				posY = 0.8676087,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6368563,
				sizeY = 0.05298013,
				image = "chu1#jdd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "qmdt2",
					varName = "attFriend_slider",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9531915,
					sizeY = 0.6250001,
					image = "tong#jdt2",
					scale9Left = 0.3,
					scale9Right = 0.3,
					percent = 60,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "qmdz2",
					varName = "attFriend_value",
					posX = 0.5,
					posY = 0.4375,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8301919,
					sizeY = 1.470955,
					text = "12/666",
					fontOutlineEnable = true,
					fontOutlineColor = "FF567D23",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "qmz2",
				varName = "attFriend_title",
				posX = 0.5,
				posY = 0.9286911,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8031906,
				sizeY = 0.06472479,
				text = "喂养等级：5",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "scdj",
				posX = 0.5665441,
				posY = 0.2335698,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6733674,
				sizeY = 0.1117745,
				text = "宠物所有技能：",
				color = "FF029133",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "scdj2",
				varName = "value",
				posX = 0.7830439,
				posY = 0.2335698,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2350631,
				sizeY = 0.1117745,
				text = "10",
				color = "FF029133",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sjan",
				varName = "attFriend_btn",
				posX = 0.5,
				posY = 0.07299579,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4715446,
				sizeY = 0.1092715,
				image = "chu1#an1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "chu1#an1",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wza",
					varName = "attFriend_lab",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.144706,
					sizeY = 0.9777725,
					text = "前往升级",
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
				etype = "Label",
				name = "scdj3",
				posX = 0.6282294,
				posY = 0.2441756,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7500134,
				sizeY = 0.07700907,
				text = "同时附加给主角(无需出战)",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tjt2",
					posX = -0.06285387,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09755921,
					sizeY = 0.5589778,
					image = "rw#xx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "scdj4",
				posX = 0.6282293,
				posY = 0.297155,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7500135,
				sizeY = 0.07700907,
				text = "喂养宠物增加属性",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tjt1",
					posX = -0.06285387,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09755921,
					sizeY = 0.5589778,
					image = "rw#xx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "scdj5",
				posX = 0.6282293,
				posY = 0.1911963,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7500135,
				sizeY = 0.07700907,
				text = "宠物满星后喂养属性翻倍",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tjt3",
					posX = -0.06285387,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09755921,
					sizeY = 0.5589778,
					image = "rw#xx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "max",
				varName = "maxLvl",
				posX = 0.5,
				posY = 0.8652894,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1084011,
				sizeY = 0.0281457,
				image = "chu1#max2",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "man",
				varName = "max",
				posX = 0.4972939,
				posY = 0.08181166,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3766937,
				sizeY = 0.2102649,
				image = "sui#max",
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
