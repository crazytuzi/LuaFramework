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
				posX = 0.4595196,
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
					posY = 0.4095401,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5988573,
					sizeY = 0.4440069,
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
						etype = "RichText",
						name = "fw1",
						varName = "name",
						posX = 0.4981712,
						posY = 0.7955045,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9217916,
						sizeY = 0.3374822,
						text = "玩法描述",
						color = "FFFFF554",
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fw2",
						varName = "tntNum",
						posX = 0.5335236,
						posY = 0.5672705,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9924962,
						sizeY = 0.198361,
						text = "持有火药数量：",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "fw3",
						varName = "miningNum",
						posX = 0.4981712,
						posY = 0.3222194,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9217916,
						sizeY = 0.198361,
						text = "可挖矿次数：",
						fontSize = 18,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "zk",
						varName = "checkResult",
						posX = 0.5,
						posY = 0.132921,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4147812,
						sizeY = 0.2170917,
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
							text = "查看收益",
							color = "FF634624",
							fontSize = 22,
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
						varName = "des4",
						posX = 0.5260817,
						posY = 0.444745,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9776126,
						sizeY = 0.198361,
						text = "区域转移获得经验：6666666",
						fontSize = 18,
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
