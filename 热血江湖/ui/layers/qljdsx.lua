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
				varName = "close_btn",
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
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3574807,
				sizeY = 0.7978032,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wk",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.02,
					sizeY = 0.8387194,
					image = "b#db5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "cdd",
						posX = 0.5000001,
						posY = 0.4616421,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9043959,
						sizeY = 0.6278923,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "top4",
							posX = 0.5,
							posY = 0.9187359,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8673851,
							sizeY = 0.105784,
							image = "chu1#top3",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "taz4",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7293959,
								sizeY = 0.9861619,
								text = "神兵变身加持",
								color = "FFF1E9D7",
								fontOutlineEnable = true,
								fontOutlineColor = "FFA47848",
								fontOutlineSize = 2,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "top5",
							posX = 0.5,
							posY = 0.4333196,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8673851,
							sizeY = 0.105784,
							image = "chu1#top3",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "taz5",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7293959,
								sizeY = 0.9861619,
								text = "永久加持",
								color = "FFF1E9D7",
								fontOutlineEnable = true,
								fontOutlineColor = "FFA47848",
								fontOutlineSize = 2,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb1",
							varName = "scroll1",
							posX = 0.5000001,
							posY = 0.6744676,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8794665,
							sizeY = 0.3455509,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb2",
							varName = "scroll2",
							posX = 0.4952717,
							posY = 0.195058,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8794665,
							sizeY = 0.3455509,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djd",
					varName = "item_bg",
					posX = 0.1854128,
					posY = 0.8198162,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2884771,
					sizeY = 0.1566802,
					image = "qiling#zhao",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "item_icon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5681818,
						sizeY = 0.8333336,
						image = "qiling#huo",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "item_name",
					posX = 0.6734744,
					posY = 0.8140457,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6189634,
					sizeY = 0.1250911,
					text = "道具名字一二三",
					color = "FF966856",
					fontSize = 24,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a1",
					varName = "close",
					posX = 0.9243941,
					posY = 0.8564606,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1420531,
					sizeY = 0.1096762,
					image = "baishi#x",
					imageNormal = "baishi#x",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "qt",
					posX = 0.5,
					posY = 0.14877,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7341867,
					sizeY = 0.1736651,
					text = "启动全部星位元，即可进化",
					color = "FFC93034",
					fontSize = 22,
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
