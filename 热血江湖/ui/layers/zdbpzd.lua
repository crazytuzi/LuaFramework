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
					varName = "leftRoots",
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
						etype = "Image",
						name = "top",
						posX = 0.5,
						posY = 0.9126694,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.986751,
						sizeY = 0.1404843,
						image = "bpzd#db",
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.436146,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.8196103,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "mz",
						varName = "titleName",
						posX = 0.5,
						posY = 0.9120522,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.941409,
						sizeY = 0.25,
						text = "帮派名称",
						color = "FFD7B886",
						fontSize = 22,
						hTextAlign = 1,
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
