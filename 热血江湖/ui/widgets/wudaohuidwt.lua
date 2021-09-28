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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.11875,
			sizeY = 0.2569444,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "rw1",
				varName = "playerRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9802632,
				sizeY = 1,
				image = "wdh#dwd",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "dj1",
					varName = "playerBtn",
					posX = 0.4910978,
					posY = 0.5029466,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9510792,
					sizeY = 0.954426,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "ddt1",
					posX = 0.5,
					posY = 0.18,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9597315,
					sizeY = 0.005405407,
					image = "wdh#huangxian",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					alpha = 0.3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txk",
					varName = "iconType",
					posX = 0.5,
					posY = 0.6062335,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8360824,
					sizeY = 0.5405407,
					image = "zdtx#txd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "icon",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zyb",
						varName = "typeImg",
						posX = 0.9189461,
						posY = 1.000767,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3061225,
						sizeY = 0.3813559,
						image = "zy#daoke",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "djd",
						posX = 0.8037993,
						posY = 0.2559153,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2857143,
						sizeY = 0.3644068,
						image = "zdte#djd2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dj",
							varName = "lvlTxt",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.007689,
							sizeY = 1.368822,
							text = "30",
							fontSize = 18,
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dzb",
					varName = "leaderIcon",
					posX = 0.141521,
					posY = 0.879673,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1879195,
					sizeY = 0.2486486,
					image = "wdh#dz",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz1",
					varName = "playerName",
					posX = 0.5,
					posY = 0.2553394,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.006999,
					sizeY = 0.1614683,
					text = "我是一个大大棒槌",
					color = "FF350909",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl1",
					posX = 0.2256062,
					posY = 0.1070361,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3273922,
					sizeY = 0.1624278,
					text = "战力:",
					color = "FFF3E113",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zlz1",
					varName = "playerPower",
					posX = 0.7091287,
					posY = 0.1070361,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6297794,
					sizeY = 0.1624278,
					text = "12134569",
					color = "FFF3E113",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dw2",
				varName = "addRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.9802632,
				sizeY = 1,
				image = "wdh#quan",
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
