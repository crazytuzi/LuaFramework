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
			name = "zmjrt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7578125,
			sizeY = 0.1666667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tdt",
				posX = 0.5021644,
				posY = 0.5024725,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.000205,
				sizeY = 0.9533879,
				image = "g#g_c4.png",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "mzd",
					posX = 0.2941943,
					posY = 0.7181259,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2675465,
					sizeY = 0.4108156,
					image = "g#g_top5.png",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zmq",
						varName = "clan_name",
						posX = 0.5,
						posY = 0.5585303,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7932085,
						sizeY = 0.9792051,
						text = "3区天下无双",
						color = "FFACFF68",
						fontSize = 24,
						fontOutlineEnable = true,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "and",
					posX = 0.8622069,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2405819,
					sizeY = 0.6617042,
					image = "w#w_smd3.png",
					alpha = 0.3,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.7016888,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.003092149,
					sizeY = 1.022668,
					image = "w#w_xian3.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zmb",
				varName = "exp_icon",
				posX = 0.07303531,
				posY = 0.5040321,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1056288,
				sizeY = 0.9083332,
				image = "zm#33",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "sz1",
					varName = "lvlicon2",
					posX = 0.6339008,
					posY = 0.4010431,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2622894,
					sizeY = 0.3603451,
					image = "zm#sz8",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sz2",
					varName = "lvlicon1",
					posX = 0.366067,
					posY = 0.4010431,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2622894,
					sizeY = 0.3603451,
					image = "zm#sz8",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "nv",
					varName = "girl_mark",
					posX = 0.5,
					posY = 0.3108194,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.019163,
					sizeY = 0.5439557,
					image = "zm#nv",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zmm",
				posX = 0.5732483,
				posY = 0.7333552,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1948252,
				sizeY = 0.4153767,
				text = "3区玄波竹林",
				color = "FFA8EEFF",
				fontSize = 22,
				fontOutlineEnable = true,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zz",
				posX = 0.1966386,
				posY = 0.3106536,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1167954,
				sizeY = 0.4153767,
				text = "宗主：",
				color = "FF5AF6D3",
				fontSize = 22,
				fontOutlineEnable = true,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zzm",
				varName = "master_name",
				posX = 0.3602025,
				posY = 0.3106535,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1948252,
				sizeY = 0.4153767,
				text = "我是一个大帅哥",
				color = "FF5AF6D3",
				fontSize = 22,
				fontOutlineEnable = true,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "sqa",
				varName = "join_btn",
				posX = 0.8644455,
				posY = 0.5024723,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1412371,
				sizeY = 0.3999999,
				image = "w#w_qq4.png",
				imageNormal = "w#w_qq4.png",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "az",
					varName = "join_desc",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.93932,
					sizeY = 0.8629364,
					text = "申请加入",
					color = "FFB0FFD9",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF145A4F",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
