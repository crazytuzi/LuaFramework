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
					posY = 0.420633,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5988573,
					sizeY = 0.4218211,
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
						name = "mb6",
						varName = "tagDesc",
						posX = 0.5783024,
						posY = 0.8033956,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.082054,
						sizeY = 0.198361,
						text = "副本层数越高获得经验越高",
						color = "FFFFF554",
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mb7",
						varName = "expValue",
						posX = 0.8615213,
						posY = 0.6814913,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5076771,
						sizeY = 0.198361,
						text = "活动倒计时：",
						fontSize = 18,
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fw1",
						varName = "name",
						posX = 0.4512598,
						posY = 0.9252999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8279688,
						sizeY = 0.198361,
						text = "标题",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fw2",
						varName = "floorNum",
						posX = 0.4512598,
						posY = 0.5595869,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8279688,
						sizeY = 0.198361,
						text = "层",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fw3",
						varName = "keyNum",
						posX = 0.4512598,
						posY = 0.4376826,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8279688,
						sizeY = 0.198361,
						text = "钥匙",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "zk",
						varName = "checkResult",
						posX = 0.5,
						posY = 0.1359953,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4621898,
						sizeY = 0.2546279,
						image = "chu1#sn1",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						imageNormal = "chu1#sn1",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "anz",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8964576,
							sizeY = 1.184687,
							text = "查看战况",
							color = "FF634624",
							fontSize = 24,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fw4",
						varName = "expSpace",
						posX = 0.4404938,
						posY = 0.6814913,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8064367,
						sizeY = 0.198361,
						text = "每03秒获得经验",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mb8",
						varName = "stateDesc",
						posX = 0.8615213,
						posY = 0.3157783,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5076771,
						sizeY = 0.198361,
						text = "活动倒计时：",
						color = "FF00FF00",
						fontSize = 18,
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mb9",
						varName = "bossDesc",
						posX = 0.3623452,
						posY = 0.3157783,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6501397,
						sizeY = 0.198361,
						text = "boss刷新时间：",
						fontSize = 18,
						fontOutlineColor = "FF27221D",
						vTextAlign = 1,
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
							posX = 0.5,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
