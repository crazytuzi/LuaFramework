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
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.6742188,
			sizeY = 0.1734554,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bpsdt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.023742,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "item_btn",
					posX = 0.09586823,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1917365,
					sizeY = 1,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d2",
					posX = 0.2158366,
					posY = 0.601494,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1499292,
					sizeY = 0.1095008,
					image = "d2#fgt",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alpha = 0.7,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wpm",
					varName = "item_name",
					posX = 0.3386277,
					posY = 0.7039234,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4083503,
					sizeY = 0.3694582,
					text = "普通强化石",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "item_bg",
					posX = 0.06978153,
					posY = 0.4829479,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1089224,
					sizeY = 0.7352195,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp",
						varName = "item_icon",
						posX = 0.507588,
						posY = 0.5187603,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.815176,
						sizeY = 0.8398849,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ddw",
					posX = 0.7094063,
					posY = 0.7297993,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1949777,
					sizeY = 0.3430402,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "sl",
						varName = "money_count",
						posX = 0.6777698,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7091525,
						sizeY = 1.07409,
						text = "999999",
						color = "FF966856",
						fontSize = 24,
						fontOutlineColor = "FFFFF6AB",
						fontOutlineSize = 2,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb",
					varName = "money_icon",
					posX = 0.6469055,
					posY = 0.7299544,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.05214369,
					sizeY = 0.3519668,
					image = "tb#tb_tongqian.png",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wpm2",
					varName = "descTxt",
					posX = 0.4786061,
					posY = 0.3605054,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6883072,
					sizeY = 0.6037852,
					text = "描述文字描述文字描述文字描述文字描述文字描述文字描述文字描述文字描述文字描述文字描述文字描述文字",
					color = "FF966856",
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "buyBtn",
					posX = 0.8997623,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1425261,
					sizeY = 0.4536461,
					image = "chu1#an3",
					imageNormal = "chu1#an3",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zna1",
						posX = 0.5,
						posY = 0.5344828,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8487151,
						sizeY = 0.8042889,
						text = "购 买",
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
					name = "ycs",
					varName = "out_icon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9948851,
					sizeY = 0.9607731,
					image = "b#bp",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.7,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ycs2",
						posX = 0.09489349,
						posY = 0.4915334,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1921765,
						sizeY = 0.7978007,
						image = "sc#sc_ysw.png",
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
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
