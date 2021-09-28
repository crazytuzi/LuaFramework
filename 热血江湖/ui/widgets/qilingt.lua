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
			posY = 0.4888888,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1796875,
			sizeY = 0.625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.008696,
				sizeY = 0.9511111,
				image = "qiling#db",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx",
				varName = "headImg",
				posX = 0.5003403,
				posY = 0.6484178,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.3066667,
				image = "qiling#suo",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "mz",
				varName = "nameImg",
				posX = 0.5,
				posY = 0.9270952,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4695652,
				sizeY = 0.1044444,
				image = "qiling#qilin",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zbz",
				varName = "weaponIcon",
				posX = 0.5043799,
				posY = 0.3624073,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1956522,
				sizeY = 0.1009569,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "equipBtn",
				posX = 0.5,
				posY = 0.2097063,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4695652,
				sizeY = 0.1333333,
				image = "qiling#an",
				imageNormal = "qiling#an",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wz1",
					varName = "equipLabel",
					posX = 0.5,
					posY = 0.4666666,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9359353,
					sizeY = 0.9497515,
					text = "装 备",
					color = "FFBF7E2A",
					fontOutlineEnable = true,
					fontOutlineColor = "FFFDE2A3",
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
				name = "btn",
				varName = "infoBtn",
				posX = 0.4956585,
				posY = 0.6526735,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8638104,
				sizeY = 0.2944501,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jdd",
				varName = "jindu",
				posX = 0.5088596,
				posY = 0.6684934,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8913044,
				sizeY = 0.4511111,
			},
			children = {
			{
				prop = {
					etype = "LoadingBar",
					name = "jdt1",
					varName = "jiewei",
					posX = 0.2373716,
					posY = 0.5662214,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3756098,
					sizeY = 0.862069,
					image = "qiling#ht",
					barDirection = 3,
				},
			},
			{
				prop = {
					etype = "LoadingBar",
					name = "jdt2",
					varName = "mifa",
					posX = 0.7478759,
					posY = 0.5612401,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3707317,
					sizeY = 0.862069,
					image = "qiling#lt",
					barDirection = 3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jdd2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "qiling#d",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc1",
					posX = 0.1763236,
					posY = 0.1004137,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "阶位",
					color = "FFFAFFC0",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc2",
					posX = 0.7992976,
					posY = 0.1035606,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "秘法",
					color = "FF34FFEE",
					fontSize = 18,
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
