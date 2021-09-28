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
			name = "jdk",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "has",
				posX = 0.5,
				posY = 0.9237436,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.1527778,
				image = "ty#jian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "padtop",
				varName = "padtop",
				posX = 0.5,
				posY = 0.9406416,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 0.1152778,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				alphaCascade = true,
				layoutType = 8,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "uu2",
					posX = 0.1849927,
					posY = 0.5602064,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2257813,
					sizeY = 0.7710842,
					image = "ty#pad2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "uu1",
					posX = 0.169735,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0703125,
					sizeY = 0.4216867,
					image = "hd#hd_hd.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wp5",
				varName = "vitRoot",
				posX = 0.5881464,
				posY = 0.9466151,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1974032,
				sizeY = 0.09027779,
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "sdf3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6886286,
					sizeY = 0.7230768,
					image = "tong#sld",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb6",
					posX = 0.1560706,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1978818,
					sizeY = 0.7692307,
					image = "tb#tb_tl.png",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "sl5",
					varName = "vit_value",
					posX = 0.4829957,
					posY = 0.4789422,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5521546,
					sizeY = 0.8239378,
					text = "999/150",
					color = "FFF4CA64",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF804000",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "j8",
					varName = "add_vit",
					posX = 0.7961039,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1978818,
					sizeY = 0.7384614,
					image = "tong#jia",
					imageNormal = "tong#jia",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ts",
					varName = "vit_info",
					posX = 0.3842995,
					posY = 0.5148206,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6321808,
					sizeY = 1.018323,
				},
			},
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
				etype = "Image",
				name = "kk1",
				posX = 0.5,
				posY = 0.4577084,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9078125,
				sizeY = 0.8763889,
				image = "b#db1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zs1",
					posX = 0.02057244,
					posY = 0.1628659,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05421687,
					sizeY = 0.3755943,
					image = "zhu#zs1",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs2",
					posX = 0.9442027,
					posY = 0.1851488,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1592083,
					sizeY = 0.4057052,
					image = "zhu#zs2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db2",
					posX = 0.491394,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9363167,
					sizeY = 0.9746434,
					image = "b#db2",
					scale9 = true,
					scale9Left = 0.47,
					scale9Right = 0.47,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "title",
					posX = 0.5,
					posY = 0.9873216,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.07401,
					sizeY = 0.08082409,
					image = "b#top",
					scale9 = true,
					scale9Left = 0.49,
					scale9Right = 0.49,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jd1",
				varName = "rootWidget",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				posX = 0.1880124,
				posY = 0.4546954,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2277502,
				sizeY = 0.8171931,
				image = "d2#dw2",
				scale9 = true,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb3",
					varName = "scroll1",
					posX = 0.4901848,
					posY = 0.4985814,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9872289,
					sizeY = 0.9756302,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sjtop",
				varName = "sjtop",
				posX = 0.04916242,
				posY = 0.6358366,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08359375,
				sizeY = 0.4986111,
				image = "tong#denglong",
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top3",
					posX = 0.471938,
					posY = 0.6473824,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4859813,
					sizeY = 0.2534819,
					image = "hd#hd_hd.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.9274268,
				posY = 0.8660722,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "padzs",
				varName = "padzs",
				posX = 0.05545116,
				posY = 0.8730147,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.028125,
				sizeY = 0.1,
				image = "ty#pad1",
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
