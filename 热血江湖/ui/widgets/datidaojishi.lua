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
			name = "dati",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4859375,
			sizeY = 0.7361111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dta",
				varName = "rootImage",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9716981,
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
					name = "hua",
					posX = 0.6562845,
					posY = 0.2685657,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8006431,
					sizeY = 0.5378641,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5,
					posY = 0.5115274,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9804553,
					sizeY = 0.5026372,
					scale9 = true,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wzsm6",
						posX = 0.5,
						posY = 0.8302836,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9737455,
						sizeY = 0.5326408,
						text = "久旱逢甘露，他乡遇故知；洞房花烛夜，金榜题名时。",
						color = "FF65944D",
						fontSize = 24,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wzsm",
					posX = 0.491936,
					posY = 0.520754,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8193381,
					sizeY = 0.2444,
					text = "科举每日19：30分正式开始，连续答对题目越多、答题速度越快，所得积分越多。",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wzsm2",
					posX = 0.2518155,
					posY = 0.1434518,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.419288,
					sizeY = 0.1464902,
					text = "倒数：",
					color = "FFC93034",
					fontSize = 24,
					fontOutlineColor = "FF102E21",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wzsm3",
					varName = "ActivitiesTime",
					posX = 0.694534,
					posY = 0.1434518,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.419288,
					sizeY = 0.1464902,
					text = "0.00219907407407407",
					color = "FFC93034",
					fontSize = 24,
					fontOutlineColor = "FF102E21",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mzd",
					posX = 0.5,
					posY = 0.8873542,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4485531,
					sizeY = 0.09708738,
					image = "chu1#zld",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wzsm4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8260303,
						sizeY = 0.9651192,
						text = "金榜题名",
						fontSize = 26,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
						colorTL = "FFF8FF2D",
						colorTR = "FFF8FF2D",
						colorBR = "FFDA7E1C",
						colorBL = "FFDA7E1C",
						useQuadColor = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wzsm5",
					posX = 0.491936,
					posY = 0.363708,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8193381,
					sizeY = 0.2444,
					text = "科举答题无论对错均有经验奖励，积分排名前150名的玩家有额外奖励；积分排名奖励通过信件发放。",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
