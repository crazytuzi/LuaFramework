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
				sizeY = 0.6527778,
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
						posY = 0.8209782,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.9881986,
						sizeY = 0.3356922,
						image = "rcb#dw",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsk",
						posX = 0.5234151,
						posY = 0.7018328,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1901235,
						sizeY = 0.09574468,
						image = "chu1#zsk",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsk2",
						posX = 0.8716981,
						posY = 0.7018328,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1901235,
						sizeY = 0.09574468,
						image = "chu1#zsk",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsk3",
						posX = 0.5234151,
						posY = 0.5951288,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1901235,
						sizeY = 0.09574468,
						image = "chu1#zsk",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zsk4",
						posX = 0.8716981,
						posY = 0.5951288,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1901235,
						sizeY = 0.09574468,
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
						varName = "txtName",
						posX = 0.4851766,
						posY = 0.9418231,
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
						varName = "imgCls",
						posX = 0.6413898,
						posY = 0.941823,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.07063092,
						sizeY = 0.1375483,
						image = "zy#daoke",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj2",
						varName = "txtLevel",
						posX = 0.8339053,
						posY = 0.9418231,
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
						posX = 0.3895069,
						posY = 0.7876474,
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
						varName = "txtVip",
						posX = 0.5281624,
						posY = 0.7876474,
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
						posY = 0.7876471,
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
						varName = "txtPower",
						posX = 0.9725608,
						posY = 0.7876474,
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
						posX = 0.3895069,
						posY = 0.6366636,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2453978,
						sizeY = 0.1940984,
						text = "在线状态：",
						color = "FF6E4228",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj8",
						varName = "txtOnline",
						posX = 0.5281624,
						posY = 0.6366636,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1555175,
						sizeY = 0.1940984,
						text = "线上",
						color = "FF0090FF",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj9",
						posX = 0.8339053,
						posY = 0.6366636,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2453978,
						sizeY = 0.1940984,
						text = "徒弟数量：",
						color = "FF6E4228",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tdj10",
						varName = "txtApprtcNum",
						posX = 0.9725609,
						posY = 0.6366636,
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
						posY = 0.8113182,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2605496,
						sizeY = 0.4432113,
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
							image = "baishi#st",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "txd",
							varName = "imgHeadBgrd",
							posX = 0.4939759,
							posY = 0.6310341,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.8855423,
							sizeY = 0.8137931,
							image = "zdtx#txd.png",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx",
								varName = "imgHeadIcon",
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
					etype = "Button",
					name = "an2",
					varName = "btnEnroll",
					posX = 0.5,
					posY = 0.09241416,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2148148,
					sizeY = 0.1404255,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "anz2",
						posX = 0.5,
						posY = 0.546875,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.958208,
						sizeY = 1.00501,
						text = "我要拜师",
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
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5040882,
					posY = 0.9372479,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3728395,
					sizeY = 0.07446808,
					image = "baishi#biaoti",
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tt",
						varName = "imgTitle",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.4503311,
						sizeY = 0.7142857,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "sfxx",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5204403,
						sizeY = 1.290086,
						text = "师父信息",
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
					varName = "btnClose",
					posX = 0.9557106,
					posY = 0.9208769,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.08024691,
					sizeY = 0.1340425,
					image = "baishi#x",
					imageNormal = "baishi#x",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xyd",
					posX = 0.5,
					posY = 0.323404,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8950617,
					sizeY = 0.2765957,
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
						etype = "Label",
						name = "tdj11",
						varName = "txtAnnounce",
						posX = 0.5068847,
						posY = 0.4703273,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9171138,
						sizeY = 0.7065306,
						text = "宣言",
						color = "FFFF632C",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "taw",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2565517,
						sizeY = 0.2769231,
						image = "chu1#top2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tdj12",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8619336,
							sizeY = 1.144093,
							text = "收徒宣言",
							color = "FF6E4228",
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
