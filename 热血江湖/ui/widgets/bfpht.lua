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
			sizeX = 0.6320313,
			sizeY = 0.1263873,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bfsqt",
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
					name = "txk",
					varName = "roleHeadBg",
					posX = 0.2528996,
					posY = 0.4534945,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1257045,
					sizeY = 0.925402,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "headimg",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "js",
					varName = "name",
					posX = 0.4905635,
					posY = 0.6776232,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3316032,
					sizeY = 0.4740151,
					text = "公认热血最强人",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF17372F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sh",
					varName = "damage",
					posX = 0.8296426,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3224944,
					sizeY = 0.5194051,
					text = "9999999999",
					color = "FFC93034",
					fontSize = 22,
					fontOutlineColor = "FF17372F",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dym",
					varName = "rank_icon",
					posX = 0.06184565,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1198254,
					sizeY = 1.02951,
					image = "bp#bp_m1.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "pm",
					varName = "rank_label",
					posX = 0.05793641,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1286801,
					sizeY = 0.6890829,
					text = "50",
					fontSize = 30,
					fontOutlineEnable = true,
					fontOutlineColor = "FF102E21",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "dj",
					varName = "level",
					posX = 0.4905635,
					posY = 0.2518699,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3316032,
					sizeY = 0.4740151,
					text = "99",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF17372F",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.6684102,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.00378396,
					sizeY = 0.96,
					image = "b#shuxian",
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
