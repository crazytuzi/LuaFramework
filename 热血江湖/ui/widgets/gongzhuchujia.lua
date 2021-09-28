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
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "z2",
				posX = 0.5,
				posY = 0.4638885,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9188007,
				sizeY = 0.9355062,
				image = "a",
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.6220188,
					posY = 0.4905233,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6549055,
					sizeY = 0.8787524,
					image = "gongzhuchujia#gongzhuchujia",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ct",
						posX = 0.5,
						posY = 0.1158538,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.1849266,
						image = "gzcj#ct",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.6260608,
					posY = 0.3281277,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6629893,
					sizeY = 0.5276653,
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
						name = "tst",
						posX = 0.5115425,
						posY = 1.24719,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4930081,
						sizeY = 0.1744433,
						image = "d#tst",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz1",
						posX = 0.1854009,
						posY = 0.2532292,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.259005,
						sizeY = 0.1636638,
						text = "需求等级：",
						color = "FFFBF798",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz2",
						varName = "need_lv",
						posX = 0.3892064,
						posY = 0.2532291,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4122587,
						sizeY = 0.1636638,
						text = "60",
						color = "FFFBF798",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz3",
						posX = 0.1854009,
						posY = 0.1661301,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.259005,
						sizeY = 0.1636638,
						text = "开启时间：",
						color = "FFFBF798",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz4",
						varName = "open_time",
						posX = 0.4301798,
						posY = 0.1661301,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4942051,
						sizeY = 0.1636638,
						text = "10：00~12：30",
						color = "FFFBF798",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz5",
						posX = 0.1854009,
						posY = 0.07903098,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.259005,
						sizeY = 0.1636638,
						text = "开启日期：",
						color = "FFFBF798",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz6",
						varName = "open_date",
						posX = 0.3892064,
						posY = 0.07903098,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4122587,
						sizeY = 0.1636638,
						text = "5",
						color = "FFFBF798",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "cj",
						posX = 0.7701117,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.2090498,
						sizeY = 0.1800704,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "asc",
							varName = "join_text",
							posX = 0.5,
							posY = 0.53125,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.003805,
							sizeY = 0.9757967,
							text = "进 入",
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
						etype = "Label",
						name = "dz9",
						varName = "not_open",
						posX = 0.5,
						posY = 1.247511,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6332906,
						sizeY = 0.1636638,
						text = "尚未开启",
						color = "FFFBF798",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz10",
						varName = "countdown_desc",
						posX = 0.3925692,
						posY = 1.247533,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3288093,
						sizeY = 0.1636638,
						text = "结束倒计时：",
						color = "FFFBF798",
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz11",
						varName = "countdown",
						posX = 0.7266074,
						posY = 1.247533,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3136994,
						sizeY = 0.1636638,
						text = "10",
						color = "FFFBF798",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.03393277,
						posY = 0.2528087,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02949783,
						sizeY = 0.05064479,
						image = "gzcj#dd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.03393277,
						posY = 0.07903099,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02949783,
						sizeY = 0.05064479,
						image = "gzcj#dd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs3",
						posX = 0.03393277,
						posY = 0.1661301,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.02949782,
						sizeY = 0.05064479,
						image = "gzcj#dd",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "cj2",
						varName = "join",
						posX = 0.7868098,
						posY = 0.1629262,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.22444,
						sizeY = 0.2053928,
						image = "bpz#ll",
						imageNormal = "bpz#ll",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "asc2",
							varName = "join_text2",
							posX = 0.5,
							posY = 0.53125,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.003805,
							sizeY = 0.9757967,
							text = "报 名",
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
						name = "ppcg",
						posX = 0.7868098,
						posY = 0.1629262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.1757044,
						sizeY = 0.1181712,
						image = "bpz#ppcg",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ph2",
					varName = "awardBtn",
					posX = 0.3533033,
					posY = 0.3281277,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07907727,
					sizeY = 0.1291636,
					image = "jjcc#jl",
					imageNormal = "jjcc#jl",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ph3",
					varName = "cartoonBt",
					posX = 0.4485369,
					posY = 0.3266431,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07992756,
					sizeY = 0.1261943,
					image = "gzcj#qq",
					imageNormal = "gzcj#qq",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an6",
				varName = "helpBtn",
				posX = 0.9346552,
				posY = 0.1131345,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05,
				sizeY = 0.0875,
				image = "tong#bz",
				imageNormal = "tong#bz",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
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
