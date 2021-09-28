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
			name = "xsysjm",
			varName = "roleInfoUI",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "tc",
				varName = "exit",
				posX = 0.6490968,
				posY = 0.8621294,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05546875,
				sizeY = 0.2222222,
				image = "zd#zd_likai.png",
				imageNormal = "zd#zd_likai.png",
				imageDisable = "zd#zd_likai.png",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "d10",
				varName = "time",
				posX = 0.6490968,
				posY = 0.7044848,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08799873,
				sizeY = 0.09952229,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djs",
					varName = "timeElapsePanel",
					posX = 0.5,
					posY = 0.6521032,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8885821,
					sizeY = 0.8632603,
					image = "d#tyd",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "djsz",
						varName = "timeElapse",
						posX = 0.5,
						posY = 0.4902764,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9,
						sizeY = 1.180872,
						text = "2:59",
						fontSize = 22,
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
				name = "tst",
				posX = 0.5,
				posY = 0.5554659,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5125,
				sizeY = 0.1722222,
				image = "d#tst",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tsz",
					varName = "des",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8494013,
					sizeY = 1.112033,
					text = "您已被淘汰，当前为队友xxxx的视角",
					color = "FFFFFF00",
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
			etype = "Grid",
			name = "yx",
			posX = 0.5,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 3,
			layoutTypeW = 3,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "tc2",
				varName = "killTips",
				posX = 0.9491797,
				posY = 0.1189128,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0828125,
				sizeY = 0.2063492,
				image = "zdte2#qhsj",
				imageNormal = "zdte2#qhsj",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
