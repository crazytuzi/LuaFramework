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
			varName = "zongjidian",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7101563,
			sizeY = 0.6378398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "shouchong",
				posX = 0.5000001,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9988998,
				sizeY = 0.8625783,
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
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 1.342978,
					image = "snjnb#snbanner",
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt",
					posX = 0.4030862,
					posY = 0.5125376,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7632158,
					sizeY = 0.9567459,
					image = "snjnb#tj",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dr",
					posX = 0.4524765,
					posY = 0.9707663,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9854181,
					sizeY = 0.2875051,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "mrlq2",
						varName = "maxDayDesc",
						posX = 0.6146219,
						posY = 0.2888942,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.030456,
						sizeY = 0.3882466,
						text = "限时购买：2020.01.01-2020.01.05",
						color = "FFF4E0C5",
						fontOutlineColor = "FFD9121E",
						vTextAlign = 1,
						colorBR = "FFFFFC00",
						colorBL = "FFFFFC00",
						wordSpaceAdd = 2,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mrlq3",
						varName = "month_card_desc",
						posX = 0.5087386,
						posY = 0.4806148,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.7297481,
						sizeY = 0.4251966,
						text = "根据时间变化，纪念币价值将会持续提升",
						color = "FFC93034",
						fontSize = 18,
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
			{
				prop = {
					etype = "Image",
					name = "lhb",
					posX = 0.6634047,
					posY = -0.04694059,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1789959,
					sizeY = 0.1411332,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "aa",
						posX = 0.6223763,
						posY = 0.5801384,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7059513,
						sizeY = 0.5902146,
						image = "b#bp",
						scale9 = true,
						scale9Left = 0.2,
						scale9Right = 0.2,
						scale9Top = 0.2,
						scale9Bottom = 0.2,
						alpha = 0.7,
						alphaCascade = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sl",
						varName = "coinCount",
						posX = 0.7034724,
						posY = 0.5748404,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.456257,
						sizeY = 0.8239378,
						text = "999",
						color = "FFFFCD55",
						fontSize = 22,
						fontOutlineColor = "FF804000",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "stq",
						varName = "coinIcon",
						posX = 0.3811336,
						posY = 0.5558187,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1845832,
						sizeY = 0.5365984,
						image = "items5#fuwenjinghua",
					},
				},
				{
					prop = {
						etype = "Button",
						name = "cz",
						varName = "coinBtn",
						posX = 0.6737666,
						posY = 0.6250055,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7505969,
						sizeY = 0.9999999,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an8",
					varName = "GetBtn",
					posX = 0.5302353,
					posY = -0.04253991,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1584045,
					sizeY = 0.1449185,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z2",
						varName = "buyBtn",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 1.019074,
						text = "购 买",
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
					name = "an4",
					varName = "otherPayBtn",
					posX = 0.2657476,
					posY = -0.03496313,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1584045,
					sizeY = 0.1449185,
					image = "chu1#fy1",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z3",
						varName = "CreditBtnText2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.016411,
						sizeY = 0.8880838,
						text = "兑 换",
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
					etype = "Scroll",
					name = "lb",
					varName = "lblist",
					posX = 0.464265,
					posY = 0.4760901,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5332642,
					sizeY = 0.7081928,
					horizontal = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb1",
					varName = "gdbl5",
					posX = 0.1671919,
					posY = 0.6690395,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1150042,
					sizeY = 0.08198676,
					text = "1/500",
					color = "FFF4E0C5",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb3",
					varName = "gdbl4",
					posX = 0.1671919,
					posY = 0.5532688,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1150042,
					sizeY = 0.08198676,
					text = "1/500",
					color = "FFF4E0C5",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb4",
					varName = "gdbl3",
					posX = 0.1671919,
					posY = 0.4420992,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1150042,
					sizeY = 0.08198676,
					text = "1/500",
					color = "FFF4E0C5",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb5",
					varName = "gdbl2",
					posX = 0.1671919,
					posY = 0.3215766,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1150042,
					sizeY = 0.08198676,
					text = "1/500",
					color = "FFF4E0C5",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb6",
					varName = "gdbl1",
					posX = 0.1671919,
					posY = 0.218423,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1150042,
					sizeY = 0.08198676,
					text = "1/500",
					color = "FFF4E0C5",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wb",
					varName = "bottomText",
					posX = 0.4988351,
					posY = -0.1319102,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9984884,
					sizeY = 0.1004901,
					text = "xxxx",
					color = "FFF4E0C5",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
