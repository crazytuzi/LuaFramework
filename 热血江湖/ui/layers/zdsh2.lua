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
			etype = "Grid",
			name = "xjd",
			posX = 0.1755276,
			posY = 0.6261908,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35,
			sizeY = 0.75,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "sq",
				varName = "closeBtn",
				posX = 0.6760367,
				posY = 0.6737968,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1026786,
				sizeY = 0.08518519,
				image = "zdte#suojin",
				imageNormal = "zdte#suojin",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sq2",
				varName = "openBtn",
				posX = 0.05223214,
				posY = 0.6737968,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1026786,
				sizeY = 0.08518519,
				image = "zdte#suojin",
				imageNormal = "zdte#suojin",
				disablePressScale = true,
				flippedX = true,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd1",
			posX = 0.1755276,
			posY = 0.6261908,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.35,
			sizeY = 0.75,
			layoutType = 7,
			layoutTypeW = 7,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "dyjd",
				varName = "teamRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				layoutType = 7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "gg",
					posX = 0.3120088,
					posY = 0.4548365,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5988573,
					sizeY = 0.353414,
					image = "b#rwd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "mb5",
						varName = "numDesc",
						posX = 0.4925646,
						posY = 0.3790645,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9403973,
						sizeY = 0.1765357,
						text = "活动倒计时：",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fw1",
						varName = "tagDesc",
						posX = 0.4925644,
						posY = 0.7357316,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9403974,
						sizeY = 0.4042832,
						text = "标题",
						color = "FFFFFC1A",
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fw3",
						varName = "scoreDesc",
						posX = 0.4925644,
						posY = 0.1437942,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9403973,
						sizeY = 0.1765357,
						text = "钥匙",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mb6",
						varName = "hpDesc",
						posX = 0.4925646,
						posY = 0.6143349,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9403973,
						sizeY = 0.1765357,
						text = "神女血量：",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "jdtd",
						varName = "other_sideImg",
						posX = 0.6759963,
						posY = 0.6163484,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6098277,
						sizeY = 0.2225876,
					},
					children = {
					{
						prop = {
							etype = "LoadingBar",
							name = "jdt1",
							varName = "bloodBar",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 1.014611,
							sizeY = 0.376653,
							image = "zd#xt",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xk",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 1.026835,
							sizeY = 0.4237347,
							image = "zd#xk",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "buffd",
					varName = "buffdRoot",
					posX = 0.4408794,
					posY = 0.6793346,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8797015,
					sizeY = 0.1148148,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "pingtai",
						varName = "room_btn",
						posX = 0.7983385,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2385144,
						sizeY = 0.7419356,
						image = "zd#zd_an.png",
						imageNormal = "zd#zd_an.png",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ptz1",
							posX = 0.5,
							posY = 0.4812944,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9581574,
							sizeY = 0.91834,
							text = "等待...",
							color = "FF634624",
							fontSize = 22,
							fontOutlineColor = "FF5D430E",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xhd",
							varName = "room_red",
							posX = 0.9015816,
							posY = 0.8483206,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.2934782,
							sizeY = 0.6511628,
							image = "zdte#hd",
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "zudui",
						varName = "team",
						posX = 0.3483617,
						posY = 0.5000002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2385144,
						sizeY = 0.7419356,
						image = "zd#zd_an.png",
						imageNormal = "zd#zd_an.png",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ptz2",
							posX = 0.5,
							posY = 0.4812944,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9581574,
							sizeY = 0.91834,
							text = "队 伍",
							color = "FF634624",
							fontSize = 22,
							fontOutlineColor = "FF5D430E",
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
						name = "renwu",
						varName = "taskBtn",
						posX = 0.1233733,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2385144,
						sizeY = 0.7419356,
						image = "zd#zd_an.png",
						imageNormal = "zd#zd_an.png",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ptz3",
							varName = "taskTitle",
							posX = 0.4893617,
							posY = 0.4812944,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9581574,
							sizeY = 0.91834,
							text = "任 务",
							color = "FF634624",
							fontSize = 22,
							fontOutlineColor = "FF5D430E",
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
						name = "boss",
						varName = "bossBtn",
						posX = 0.5733501,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2385143,
						sizeY = 0.7419356,
						image = "zd#zd_an.png",
						imageNormal = "zd#zd_an.png",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ptz4",
							posX = 0.5,
							posY = 0.4812944,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9581574,
							sizeY = 0.91834,
							text = "输 出",
							color = "FF634624",
							fontSize = 22,
							fontOutlineColor = "FF5D430E",
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
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	chu = {
		dyjd = {
			moveP = {{0, {-0.3, 0.5, 0}}, {300, {0.5, 0.5, 0}}, },
		},
	},
	ru = {
		dyjd = {
			moveP = {{0, {0.5, 0.5, 0}}, {200, {-0.3, 0.5, 0}}, },
		},
	},
	c_dakai = {
	},
	c_dakai2 = {
	},
	c_chu = {
		{0,"chu", 1, 0},
	},
	c_ru = {
		{0,"ru", 1, 0},
	},
	c_dakai3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
