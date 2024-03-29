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
					name = "tq",
					posX = 0.5,
					posY = 0.5272112,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.056662,
					sizeY = 1.02373,
					image = "tequanka#tequanka",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "mrlq2",
						varName = "month_card_desc",
						posX = 0.667527,
						posY = 0.04311184,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6372839,
						sizeY = 0.1301203,
						text = "特权卡描述",
						color = "FFC93034",
						fontSize = 22,
						fontOutlineColor = "FFD9121E",
						hTextAlign = 2,
						vTextAlign = 1,
						colorBR = "FFFFFC00",
						colorBL = "FFFFFC00",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dr",
					posX = 0.2987417,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5920641,
					sizeY = 0.9689292,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj1",
						varName = "item_bg1",
						posX = 0.3125803,
						posY = 0.5133058,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.2431341,
						sizeY = 0.2199871,
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
							posY = 0.206733,
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
						posX = 0.6733251,
						posY = 0.5133058,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 0.2431341,
						sizeY = 0.2199871,
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
							posY = 0.206733,
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
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an8",
					varName = "GetBtn",
					posX = 0.7544636,
					posY = 0.3564511,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.2664625,
					sizeY = 0.1496599,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z2",
						varName = "GetBtnText",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 1.019074,
						text = "续 费",
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
					etype = "Button",
					name = "an",
					varName = "topup",
					posX = 0.7544636,
					posY = 0.3340885,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2664625,
					sizeY = 0.1496599,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z",
						varName = "CreditBtnText",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 0.8880838,
						text = "储  值",
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
					etype = "Image",
					name = "tqd",
					posX = 0.2484996,
					posY = 0.3967486,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.45102,
					sizeY = 0.6456879,
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "tqn",
						varName = "daw",
						posX = 0.5999963,
						posY = 0.3741597,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.281357,
						sizeY = 0.6416169,
						text = "特权内容",
						lineSpace = 4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an3",
					varName = "otherPayBtn",
					posX = 0.7544636,
					posY = 0.1617509,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2664625,
					sizeY = 0.1496599,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z3",
						varName = "CreditBtnText2",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 0.8880838,
						text = "其他金额",
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
