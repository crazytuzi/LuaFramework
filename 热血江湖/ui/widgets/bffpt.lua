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
			sizeX = 0.5742188,
			sizeY = 0.1263873,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bffpt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.98,
				sizeY = 0.95,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "item_bg",
					posX = 0.06884356,
					posY = 0.4713873,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1041233,
					sizeY = 0.8675645,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "wp",
						varName = "item_icon",
						posX = 0.4981201,
						posY = 0.5471479,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
						image = "items#items_chujilianbaozhen.png",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wpm",
					varName = "item_name",
					posX = 0.3526697,
					posY = 0.673077,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4511746,
					sizeY = 0.5783763,
					text = "物品名称",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF17372F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wpm2",
					varName = "desc",
					posX = 0.2351104,
					posY = 0.3102811,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2160561,
					sizeY = 0.5783763,
					text = "剩余多少件",
					color = "FFC93034",
					fontOutlineColor = "FF17372F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xq",
					varName = "detail_btn",
					posX = 0.5592102,
					posY = 0.476865,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1041233,
					sizeY = 0.8559968,
					image = "bp#bp_xiang.png",
					imageNormal = "bp#bp_xiang.png",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "sq",
					varName = "apply_btn",
					posX = 0.7141518,
					posY = 0.4884458,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1760261,
					sizeY = 0.8315013,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wpm3",
					varName = "apply_desc",
					posX = 0.4327238,
					posY = 0.3102811,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2494174,
					sizeY = 0.5783763,
					text = "已有10人申请",
					color = "FFC93034",
					fontOutlineColor = "FF17372F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ant1",
					varName = "have_icon",
					posX = 0.7150514,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1707622,
					sizeY = 0.6709165,
					image = "chu1#an3",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dsa",
						posX = 0.5,
						posY = 0.5344828,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9314313,
						sizeY = 1.045065,
						text = "已申请",
						color = "FF1E582B",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF8DE3C4",
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
					name = "ant2",
					varName = "no_icon",
					posX = 0.7150514,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1707622,
					sizeY = 0.6709165,
					image = "chu1#an4",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dsa2",
						posX = 0.5,
						posY = 0.5344828,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9314313,
						sizeY = 1.045065,
						text = "申 请",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF936D51",
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
					name = "zq",
					varName = "get_byself",
					posX = 0.8946317,
					posY = 0.4884022,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1707622,
					sizeY = 0.6709165,
					image = "chu1#an4",
					imageNormal = "chu1#an4",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dsa3",
						posX = 0.5,
						posY = 0.5344828,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9314313,
						sizeY = 1.045065,
						text = "自 取",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF936D51",
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
