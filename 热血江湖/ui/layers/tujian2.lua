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
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "close",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "ka",
				posX = 0.5,
				posY = 0.5693299,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.272988,
				sizeY = 0.6604555,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "mc",
					varName = "name",
					posX = 0.5,
					posY = -0.2530662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.127057,
					sizeY = 0.2359127,
					text = "消耗道具解锁",
					color = "FFFFFF80",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tu",
					varName = "image",
					posX = 0.5485836,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8041791,
					sizeY = 0.9189785,
					image = "tujian#huolong",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kpd",
					varName = "back",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9615808,
					sizeY = 0.9673458,
					image = "tujian2#cheng4",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zz",
					varName = "cover",
					posX = 0.500652,
					posY = 0.503195,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9301152,
					sizeY = 0.9469484,
					image = "b#bp",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "js",
				varName = "unlock",
				posX = 0.4999991,
				posY = 0.1769195,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1235795,
				sizeY = 0.08333334,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "jsz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8680338,
					sizeY = 1.002351,
					text = "解 锁",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
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
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	guang = {
		sg = {
			alpha = {{0, {0}}, {500, {0.8}}, {750, {0.8}}, {1500, {0}}, },
		},
	},
	za = {
		dst = {
			alpha = {{0, {1}}, },
		},
		sg = {
			alpha = {{0, {1}}, },
		},
		st = {
			alpha = {{0, {1}}, },
		},
	},
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
	gy15 = {
	},
	gy16 = {
	},
	gy17 = {
	},
	gy18 = {
	},
	gy19 = {
	},
	gy20 = {
	},
	gy21 = {
	},
	gy22 = {
	},
	c_dakai = {
		{0,"guang", -1, 0},
		{0,"za", 1, 0},
		{2,"heiyan", 1, 0},
		{2,"yanwu", 1, 0},
		{2,"xx", 1, 0},
		{2,"qpx", 1, 0},
		{2,"gy", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
