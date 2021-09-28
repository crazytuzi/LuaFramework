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
				varName = "imgBK",
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
				sizeX = 0.3179688,
				sizeY = 0.731295,
				image = "b#cs",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "mw",
					posX = 0.5024512,
					posY = 0.7940792,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7898556,
					sizeY = 0.2829009,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "aa",
						posX = 0.4886068,
						posY = 0.4451314,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.053166,
						sizeY = 0.8322935,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bb3",
						varName = "quality",
						posX = 0.1555645,
						posY = 0.4367439,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2924056,
						sizeY = 0.6310567,
						image = "djk#kzi",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "b3",
							varName = "icon",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8229166,
							sizeY = 0.8125,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "cc3",
						varName = "name",
						posX = 0.4863053,
						posY = 0.5909009,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3317336,
						sizeY = 0.3708893,
						text = "者·水密文",
						color = "FFFF7E2D",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "cc4",
						varName = "level",
						posX = 0.723858,
						posY = 0.5909008,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2044078,
						sizeY = 0.3708897,
						text = "3级",
						color = "FFFF7E2D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "sl",
						varName = "num",
						posX = 0.6027627,
						posY = 0.3145502,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5646486,
						sizeY = 0.3271656,
						text = "数量：100",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "kk",
					posX = 0.5,
					posY = 0.4692796,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.831849,
					sizeY = 0.2747011,
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
						name = "top2",
						posX = 0.5050901,
						posY = 0.9942215,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5493814,
						sizeY = 0.2488955,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "top3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.8874494,
							text = "获得",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FF966856",
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
						name = "lb",
						varName = "scroll",
						posX = 0.5000001,
						posY = 0.4541402,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9278844,
						sizeY = 0.7466865,
						horizontal = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gbb",
					varName = "close",
					posX = 0.9296345,
					posY = 0.9447377,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1597051,
					sizeY = 0.1196508,
					image = "baishi#x",
					imageNormal = "baishi#x",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "low",
					varName = "low",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.999098,
					sizeY = 0.9872205,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "a1",
						varName = "ok",
						posX = 0.5,
						posY = 0.08298276,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3760373,
						sizeY = 0.1115806,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "f1",
							varName = "no_name",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9380173,
							sizeY = 1.123097,
							text = "回 收",
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
						name = "k1",
						posX = 0.4835475,
						posY = 0.2317295,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8796054,
						sizeY = 0.2019442,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "sld",
							posX = 0.3113164,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5544986,
							sizeY = 0.6159096,
							image = "sl#sld",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "ttt",
								varName = "curNum",
								posX = 0.5038438,
								posY = 0.5017754,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5591041,
								sizeY = 0.8268532,
								text = "0",
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
							etype = "Button",
							name = "jian",
							varName = "jian",
							posX = 0.1004596,
							posY = 0.5109386,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1415221,
							sizeY = 0.6137328,
							image = "sl#jian",
							imageNormal = "sl#jian",
							disablePressScale = true,
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "jia",
							varName = "jia",
							posX = 0.5233031,
							posY = 0.5109386,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1415221,
							sizeY = 0.6137329,
							image = "sl#jia",
							imageNormal = "sl#jia",
							disablePressScale = true,
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "jj",
							varName = "ten",
							posX = 0.710428,
							posY = 0.4810096,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2180741,
							sizeY = 0.7342141,
							image = "sl#shi",
							imageNormal = "sl#shi",
							disablePressScale = true,
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
					},
					{
						prop = {
							etype = "Button",
							name = "max",
							varName = "max",
							posX = 0.9207186,
							posY = 0.4810096,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2180741,
							sizeY = 0.7342141,
							image = "sl#max",
							imageNormal = "sl#max",
							disablePressScale = true,
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "high",
					varName = "high",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9941884,
					sizeY = 0.9962978,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "cancel",
						varName = "cancel",
						posX = 0.2730876,
						posY = 0.1520498,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3778941,
						sizeY = 0.110564,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "t",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9168993,
							sizeY = 0.7760145,
							text = "取 消",
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
						etype = "Button",
						name = "huis",
						varName = "ok2",
						posX = 0.7396254,
						posY = 0.1520498,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.3778941,
						sizeY = 0.110564,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tt",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9107193,
							sizeY = 0.7652022,
							text = "回 收",
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
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 1,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6486486,
					sizeY = 0.09875935,
					image = "chu1#top",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "top1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5113636,
						sizeY = 0.4807692,
						image = "biaoti#miwenhuishou",
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
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
	gy23 = {
	},
	gy24 = {
	},
	gy25 = {
	},
	gy26 = {
	},
	gy27 = {
	},
	gy28 = {
	},
	gy29 = {
	},
	gy30 = {
	},
	gy31 = {
	},
	gy32 = {
	},
	gy33 = {
	},
	gy34 = {
	},
	gy35 = {
	},
	gy36 = {
	},
	gy37 = {
	},
	gy38 = {
	},
	gy39 = {
	},
	gy40 = {
	},
	gy41 = {
	},
	gy42 = {
	},
	gy43 = {
	},
	gy44 = {
	},
	gy45 = {
	},
	gy46 = {
	},
	gy47 = {
	},
	gy48 = {
	},
	gy49 = {
	},
	gy50 = {
	},
	gy51 = {
	},
	gy52 = {
	},
	gy53 = {
	},
	gy54 = {
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
