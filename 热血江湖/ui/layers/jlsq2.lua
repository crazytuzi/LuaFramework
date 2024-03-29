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
				sizeX = 0.43125,
				sizeY = 0.5222222,
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
					etype = "Grid",
					name = "tp3",
					posX = 0.27,
					posY = 0.4658765,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6474815,
					sizeY = 0.2982801,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "fg3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5176131,
						sizeY = 2.67491,
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
							name = "dw1",
							posX = 0.5053978,
							posY = 0.6299987,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7081081,
							sizeY = 0.4299999,
							image = "jlsq#dw1",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz5",
						varName = "name1",
						posX = 0.5,
						posY = 1.557708,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6438599,
						sizeY = 0.3855708,
						text = "伤害加深",
						color = "FFA05C21",
						fontSize = 24,
						fontOutlineColor = "FF00152E",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz6",
						varName = "level1",
						posX = 0.5,
						posY = 0.8477345,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4840277,
						sizeY = 0.3855711,
						text = "Lv.5",
						color = "FFCC2A00",
						fontSize = 22,
						fontOutlineColor = "FF00152E",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a2",
						varName = "loseBtn",
						posX = 0.5,
						posY = -0.0003066461,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.408759,
						sizeY = 0.4941018,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz2",
							varName = "ok_word",
							posX = 0.5,
							posY = 0.5469565,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8313926,
							sizeY = 0.9422306,
							text = "领 取",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF2A6953",
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
						name = "tl",
						varName = "itemIcon1",
						posX = 0.4050275,
						posY = -0.5283735,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1259059,
						sizeY = 0.4372896,
						image = "tb#tl",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "slz",
							varName = "itemNum1",
							posX = 2.422805,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.715136,
							sizeY = 0.9253296,
							text = "x55",
							color = "FF966856",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "btn2",
							varName = "itemBtn1",
							posX = 0.5179417,
							posY = 0.5173008,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.25711,
							sizeY = 0.9697103,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "tp4",
					posX = 0.73,
					posY = 0.4658765,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6474815,
					sizeY = 0.2982801,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "fg4",
						posX = 0.5,
						posY = 0.5000001,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5176131,
						sizeY = 2.67491,
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
							name = "dw2",
							posX = 0.5053978,
							posY = 0.6299987,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7081081,
							sizeY = 0.4299999,
							image = "jlsq#dw2",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz7",
						varName = "name2",
						posX = 0.5,
						posY = 1.557708,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6438599,
						sizeY = 0.3855708,
						text = "伤害加深",
						color = "FFA05C21",
						fontSize = 24,
						fontOutlineColor = "FF00152E",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tpz8",
						varName = "level2",
						posX = 0.5,
						posY = 0.8477346,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4840277,
						sizeY = 0.3855711,
						text = "Lv.5",
						color = "FFCC2A00",
						fontSize = 26,
						fontOutlineColor = "FF00152E",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "a3",
						varName = "saveBtn",
						posX = 0.5,
						posY = -0.0003066461,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.408759,
						sizeY = 0.4941018,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz3",
							varName = "ok_word2",
							posX = 0.5,
							posY = 0.5469564,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8313926,
							sizeY = 0.9422306,
							text = "领 取",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
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
						name = "tl2",
						posX = 0.4050275,
						posY = -0.5283735,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1259059,
						sizeY = 0.4372896,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "slz2",
							varName = "itemNum2",
							posX = 2.422805,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.715136,
							sizeY = 0.9253296,
							text = "x55",
							color = "FF966856",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "djt",
							varName = "itemIcon2",
							posX = 0.5068739,
							posY = 0.5205284,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.746837,
							sizeY = 0.7543126,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "btn1",
							varName = "itemBtn2",
							posX = 0.5179417,
							posY = 0.5173008,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.25711,
							sizeY = 0.9697103,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hua",
					posX = 0.6374477,
					posY = 0.3805093,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9021739,
					sizeY = 0.7367021,
					image = "hua1#hua1",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.997327,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4782609,
					sizeY = 0.1382979,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "topz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5151514,
						sizeY = 0.4807691,
						image = "biaoti#jlsq",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close",
				posX = 0.7012346,
				posY = 0.7149182,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				disablePressScale = true,
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
			scale = {{0, {0, 0, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
