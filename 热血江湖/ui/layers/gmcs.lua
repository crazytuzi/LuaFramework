--version = 1
local l_fileType = "layer"

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
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "imgBK",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.45,
				sizeY = 0.4348738,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5,
					posY = 0.6124713,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.932687,
					sizeY = 0.6609249,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.6038902,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8865404,
					sizeY = 0.6765317,
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "k1",
						posX = 0.5,
						posY = 0.4401355,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9215352,
						sizeY = 0.3701542,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "sld",
							posX = 0.463778,
							posY = 0.4954239,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5916304,
							sizeY = 0.9109728,
							image = "sl#sld",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "jian",
							varName = "jian_btn",
							posX = 0.2339258,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.132815,
							sizeY = 0.9109728,
							image = "sl#jian",
							imageNormal = "sl#jian",
							disablePressScale = true,
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl",
							varName = "sale_count",
							posX = 0.4660659,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3081704,
							sizeY = 0.5429788,
							text = "231/999",
							fontSize = 26,
							fontOutlineEnable = true,
							fontOutlineColor = "FF2E1410",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "jia",
							varName = "jia_btn",
							posX = 0.6905837,
							posY = 0.4999999,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.132815,
							sizeY = 0.9109728,
							image = "sl#jia",
							imageNormal = "sl#jia",
							disablePressScale = true,
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "max",
							varName = "max_btn",
							posX = 0.8948494,
							posY = 0.4349305,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2028447,
							sizeY = 1.080153,
							image = "sl#max",
							imageNormal = "sl#max",
							disablePressScale = true,
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "hua",
						posX = 0.2899942,
						posY = 0.1466652,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2600072,
						sizeY = 0.225663,
						text = "花费：",
						color = "FF966856",
						fontSize = 22,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "yb",
						varName = "money_icon",
						posX = 0.5022221,
						posY = 0.158542,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1199657,
						sizeY = 0.2596873,
						image = "tb#tb_yuanbao.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo",
							posX = 0.6851878,
							posY = 0.2777126,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.463745,
							sizeY = 0.4637451,
							image = "tb#suo",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "hua2",
						varName = "money_count",
						posX = 0.7061355,
						posY = 0.1466652,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2600072,
						sizeY = 0.225663,
						text = "6545",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "z1",
					varName = "desc2",
					posX = 0.5,
					posY = 0.7539185,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238426,
					sizeY = 0.1459144,
					text = "升级至VIP6：每日可购买次数+6",
					color = "FFC93034",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "cancel_btn",
					posX = 0.2484894,
					posY = 0.1420529,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3215751,
					sizeY = 0.208573,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f1",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8995844,
						sizeY = 0.963034,
						text = "取 消",
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
					etype = "Button",
					name = "a2",
					varName = "ok_btn",
					posX = 0.7540076,
					posY = 0.1420529,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3215751,
					sizeY = 0.208573,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "f2",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8995844,
						sizeY = 0.963034,
						text = "确 定",
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
					etype = "RichText",
					name = "z2",
					varName = "desc1",
					posX = 0.5,
					posY = 0.8697041,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8238426,
					sizeY = 0.1459144,
					text = "本日您还可以购买3次",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
