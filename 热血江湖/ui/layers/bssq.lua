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
				sizeX = 0.6328125,
				sizeY = 0.5510201,
				image = " b#cs",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
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
					sizeX = 1,
					sizeY = 1,
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
						name = "hua",
						posX = 0.5,
						posY = 0.7947404,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9881986,
						sizeY = 0.3881676,
						image = "rcb#dw",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsk",
						posX = 0.5221514,
						posY = 0.5741969,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1901235,
						sizeY = 0.113426,
						image = "chu1#zsk",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsk2",
						posX = 0.8716981,
						posY = 0.5741969,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1901235,
						sizeY = 0.113426,
						image = "chu1#zsk",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsk3",
						posX = 0.520915,
						posY = 0.4397549,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1901235,
						sizeY = 0.113426,
						image = "chu1#zsk",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jqd",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7865613,
					sizeY = 0.6960803,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "mz",
						varName = "name",
						posX = 0.4851766,
						posY = 0.7861158,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4445148,
						sizeY = 0.1833978,
						text = "你是一个大大草包",
						color = "FF6E4228",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ttxk",
						varName = "occupation",
						posX = 0.6413898,
						posY = 0.7861159,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.07063092,
						sizeY = 0.1629496,
						image = "zy#daoke",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj2",
						posX = 0.8339053,
						posY = 0.7861159,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2453978,
						sizeY = 0.1940984,
						text = "Lv.40",
						color = "FF6E4228",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj3",
						posX = 0.3856181,
						posY = 0.6065924,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2453978,
						sizeY = 0.1940984,
						text = "贵族等级：",
						color = "FF6E4228",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj4",
						posX = 0.5281624,
						posY = 0.6065924,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1555175,
						sizeY = 0.1940984,
						text = "3",
						color = "FFFF632C",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj5",
						posX = 0.8339053,
						posY = 0.6065921,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2453978,
						sizeY = 0.1940984,
						text = "最高战力：",
						color = "FF6E4228",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj6",
						posX = 0.9725608,
						posY = 0.6065924,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1555175,
						sizeY = 0.1940984,
						text = "3",
						color = "FFFF632C",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj7",
						posX = 0.3856181,
						posY = 0.4134509,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2453978,
						sizeY = 0.1940984,
						text = "昨日活跃：",
						color = "FF6E4228",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj8",
						posX = 0.5265905,
						posY = 0.413451,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1555175,
						sizeY = 0.1940984,
						text = "3",
						color = "FFFF632C",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dk1",
						posX = 0.09571277,
						posY = 0.6809586,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2605496,
						sizeY = 0.5250597,
						image = "baishi#qi",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "bst",
							posX = 0.5,
							posY = 0.06623092,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3493976,
							sizeY = 0.737931,
							image = "baishi#bs",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "txd2",
							varName = "iconType",
							posX = 0.4939759,
							posY = 0.6310341,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.8855423,
							sizeY = 0.8137932,
							image = "zdtx#txd.png",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx2",
								varName = "icon",
								posX = 0.5054789,
								posY = 0.6925332,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7210885,
								sizeY = 1.110169,
							},
						},
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "zl9",
					varName = "count2",
					posX = 0.5,
					posY = 0.286845,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5317041,
					sizeY = 0.1109918,
					text = "有个玩家想要拜您为师",
					color = "FFFF632C",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an2",
					varName = "buyBtn",
					posX = 0.7,
					posY = 0.1276545,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2148148,
					sizeY = 0.1663581,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.958208,
						sizeY = 1.00501,
						text = "同 意",
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
					name = "top",
					posX = 0.5,
					posY = 0.9217665,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3728395,
					sizeY = 0.08822022,
					image = "baishi#biaoti",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tt",
						varName = "title_desc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.7598994,
						sizeY = 0.4807692,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "taz",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6041324,
						sizeY = 1.425847,
						text = "拜师申请",
						color = "FF6E4228",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an3",
					posX = 0.3,
					posY = 0.1276545,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2148148,
					sizeY = 0.1663581,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.958208,
						sizeY = 1.00501,
						text = "拒 绝",
						fontSize = 24,
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
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	dk = {
		ysjm = {
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
