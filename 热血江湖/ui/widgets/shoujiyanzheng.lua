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
				name = "shouchong",
				varName = "ShouChong",
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
					name = "nrt",
					posX = 0.5978958,
					posY = 0.5559454,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.209801,
					sizeY = 1.135157,
					image = "yueka#yueka",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "topup",
					posX = 0.3267008,
					posY = 0.1437023,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2496172,
					sizeY = 0.1451247,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z",
						varName = "CreditBtnText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 0.8880838,
						text = "验 证",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF2A6953",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dr",
					posX = 0.5046071,
					posY = 0.2895591,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9854181,
					sizeY = 0.4436445,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj1",
						varName = "item_bg1",
						posX = 0.1653,
						posY = 0.9947478,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1476352,
						sizeY = 0.4906791,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt1",
							varName = "item_icon1",
							posX = 0.5,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an1",
							varName = "Btn1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "sld",
							varName = "count_bg1",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8526314,
							sizeY = 0.2708333,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo7",
							varName = "Item_suo1",
							posX = 0.1852118,
							posY = 0.2319877,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.3157894,
							sizeY = 0.3125,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl",
							varName = "item_count1",
							posX = 0.5257913,
							posY = 0.2588165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj2",
						varName = "item_bg2",
						posX = 0.3194611,
						posY = 0.9947478,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1476352,
						sizeY = 0.4906791,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt2",
							varName = "item_icon2",
							posX = 0.5,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an2",
							varName = "Btn2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "sld2",
							varName = "count_bg2",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8526314,
							sizeY = 0.2708333,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo6",
							varName = "Item_suo2",
							posX = 0.1852118,
							posY = 0.2319877,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3157894,
							sizeY = 0.3125,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl2",
							varName = "item_count2",
							posX = 0.5257913,
							posY = 0.2588165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj3",
						varName = "item_bg3",
						posX = 0.4736221,
						posY = 0.9947478,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1476352,
						sizeY = 0.4906791,
						image = "djk#kbai",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "djt3",
							varName = "item_icon3",
							posX = 0.5,
							posY = 0.5352941,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "an3",
							varName = "Btn3",
							posX = 0.4873505,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "sld3",
							varName = "count_bg3",
							posX = 0.5,
							posY = 0.2395833,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8526314,
							sizeY = 0.2708333,
							image = "sc#sc_sld.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "cuo5",
							varName = "Item_suo3",
							posX = 0.1852118,
							posY = 0.2319877,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3157894,
							sizeY = 0.3125,
							image = "tb#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl3",
							varName = "item_count3",
							posX = 0.5257913,
							posY = 0.2588165,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7744884,
							sizeY = 0.4154173,
							text = "99",
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mrlq2",
						posX = 0.316919,
						posY = 1.914299,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "关联手机号、即可领取奖励",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FFD9121E",
						hTextAlign = 1,
						vTextAlign = 1,
						colorBR = "FFFFFC00",
						colorBL = "FFFFFC00",
						wordSpaceAdd = 2,
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
