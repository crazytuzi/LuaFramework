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
				posX = 0.5000001,
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
				etype = "Image",
				name = "meili",
				varName = "UIRoot",
				posX = 0.5,
				posY = 0.4749998,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7410796,
				sizeY = 0.7210377,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.2,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt",
					posX = 0.5,
					posY = 0.3742093,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9102336,
					sizeY = 0.6369009,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.4999999,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9869948,
						sizeY = 0.9763331,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tsz",
						posX = 0.5,
						posY = -0.04042224,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.8353519,
						sizeY = 0.25,
						text = "提示玩家话语",
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
					etype = "Label",
					name = "wz1",
					posX = 0.5342994,
					posY = 0.8802958,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1298915,
					sizeY = 0.1108723,
					text = "魅力值：",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF112927",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz2",
					varName = "charm_value",
					posX = 0.6292803,
					posY = 0.8802958,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1166335,
					sizeY = 0.1108723,
					text = "96446",
					color = "FF8F61AC",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz3",
					posX = 0.7518967,
					posY = 0.8802959,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1298915,
					sizeY = 0.1108723,
					text = "等级：",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF112927",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz4",
					varName = "charm_level",
					posX = 0.8352619,
					posY = 0.8802958,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1332344,
					sizeY = 0.1108724,
					text = "Lv.100",
					color = "FF8F61AC",
					fontSize = 22,
					fontOutlineColor = "FF521D78",
					vTextAlign = 1,
					colorTL = "FFFFB2F0",
					colorTR = "FFFFB2F0",
					colorBR = "FFDB50EB",
					colorBL = "FFDB50EB",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jd1",
					posX = 0.6609774,
					posY = 0.7947956,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4480372,
					sizeY = 0.06163955,
					image = "chu1#jdd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "LoadingBar",
						name = "jdt",
						varName = "charm_bar",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9647059,
						sizeY = 0.6250001,
						image = "tong#jdt",
						percent = 50,
						imageHead = "ty#guang",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "dz",
						varName = "bar_value",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8301919,
						sizeY = 2.00012,
						text = "100/7000",
						fontOutlineEnable = true,
						fontOutlineColor = "FF5B7838",
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
					name = "s",
					varName = "refresh_btn",
					posX = 0.9305819,
					posY = 0.7954431,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04638503,
					sizeY = 0.07897568,
					image = "te#sx",
					imageNormal = "te#sx",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mldw",
					varName = "titleBg",
					posX = 0.2205627,
					posY = 0.8798912,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5397531,
					sizeY = 0.2465582,
					image = "ch/chdw1",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mltp",
					varName = "charm_name",
					posX = 0.2205627,
					posY = 0.8798912,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1349383,
					sizeY = 0.1232791,
					image = "ch/weizhenbafang",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "accept_btn",
				posX = 0.2339219,
				posY = 0.6587213,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1203125,
				sizeY = 0.08055556,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "yz",
					posX = 0.5,
					posY = 0.5350872,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7153199,
					sizeY = 0.8895276,
					text = "收 到",
					color = "FF966856",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
					lineSpaceAdd = -4,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an2",
				varName = "give_btn",
				posX = 0.3611607,
				posY = 0.6587212,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1203125,
				sizeY = 0.08055556,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "yz2",
					posX = 0.5,
					posY = 0.5350878,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7153199,
					sizeY = 0.8895277,
					text = "送 出",
					color = "FF966856",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
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
				name = "gb",
				varName = "close_btn",
				posX = 0.8556973,
				posY = 0.7913491,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5007792,
				posY = 0.8349043,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "hyt",
					varName = "titleImg",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3143939,
					sizeY = 0.4807692,
					image = "biaoti#meili",
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
