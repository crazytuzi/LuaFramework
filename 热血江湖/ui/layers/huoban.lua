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
				name = "suicong",
				varName = "UIRoot",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Grid",
					name = "zhuye",
					varName = "main_root",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8752496,
					sizeY = 0.8258766,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "diji",
						varName = "lowLvlBg",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9910498,
						sizeY = 1.022542,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "bjt1",
							posX = 0.5,
							posY = 0.55,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.393641,
							sizeY = 1.216808,
							image = "hbdj#hbdj",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zs1",
								posX = 0.9678555,
								posY = 0.4682882,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.04400979,
								sizeY = 0.8775166,
								image = "huoban#zs",
							},
						},
						},
					},
					{
						prop = {
							etype = "Button",
							name = "btn",
							varName = "dj_fill_code_btn",
							posX = 0.7993621,
							posY = 0.1241772,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1976313,
							sizeY = 0.1347472,
							image = "chu1#an2",
							imageNormal = "chu1#an2",
							disablePressScale = true,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "btz",
								posX = 0.5,
								posY = 0.530303,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8503845,
								sizeY = 0.785064,
								text = "填写伙伴码",
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
					{
						prop = {
							etype = "Button",
							name = "bz",
							varName = "dj_help_btn",
							posX = 1.035177,
							posY = 0.3567654,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.04997573,
							sizeY = 0.08983144,
							image = "huoban#bz",
							imageNormal = "huoban#bz",
							disablePressScale = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "gaoji",
						varName = "highLvlBg",
						posX = 0.5,
						posY = 0.505561,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9910498,
						sizeY = 1.022542,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "bjt2",
							posX = 0.5,
							posY = 0.55,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.393641,
							sizeY = 1.216808,
							image = "hbgj#hbgj",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zs2",
								posX = 0.9678555,
								posY = 0.4682882,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.04400979,
								sizeY = 0.8775166,
								image = "huoban#zs",
							},
						},
						},
					},
					{
						prop = {
							etype = "Button",
							name = "btn2",
							varName = "copy_code_btn",
							posX = 0.6408409,
							posY = 0.1187388,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1976313,
							sizeY = 0.1347472,
							image = "chu1#an2",
							imageNormal = "chu1#an2",
							disablePressScale = true,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "btz2",
								posX = 0.5,
								posY = 0.530303,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8503845,
								sizeY = 0.785064,
								text = "复制伙伴码",
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
					{
						prop = {
							etype = "Label",
							name = "cs4",
							varName = "codeLabel",
							posX = 0.7977802,
							posY = 0.29655,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5679061,
							sizeY = 0.1471707,
							text = "我的伙伴码：FDSASHUGFA654",
							color = "FF3F4158",
							fontSize = 18,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "bz2",
							varName = "gj_help_btn",
							posX = 1.065869,
							posY = 0.297645,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.04997573,
							sizeY = 0.08983144,
							image = "huoban#bz",
							imageNormal = "huoban#bz",
							disablePressScale = true,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "btn3",
							varName = "gj_fill_code_btn",
							posX = 0.3908392,
							posY = 0.1187388,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1976313,
							sizeY = 0.1347472,
							image = "chu1#an2",
							imageNormal = "chu1#an2",
							disablePressScale = true,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "btz3",
								varName = "fillHuoBanCodeTxt",
								posX = 0.5,
								posY = 0.530303,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.30458,
								sizeY = 0.785064,
								text = "填写伙伴码",
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
					{
						prop = {
							etype = "Button",
							name = "btn4",
							varName = "copy_all_btn",
							posX = 0.8908409,
							posY = 0.1187388,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1976313,
							sizeY = 0.1347472,
							image = "chu1#an2",
							imageNormal = "chu1#an2",
							disablePressScale = true,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "btz4",
								posX = 0.5,
								posY = 0.530303,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.8503845,
								sizeY = 0.785064,
								text = "添加欢迎语",
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
			},
			{
				prop = {
					etype = "Grid",
					name = "youqing",
					varName = "friend_root",
					posX = 0.5,
					posY = 0.5011387,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.8752496,
					sizeY = 0.8258766,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "bjt3",
						posX = 0.5,
						posY = 0.5542787,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.381168,
						sizeY = 1.244237,
						image = "hbdb#hbdb",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zs3",
							posX = 0.9678555,
							posY = 0.4682882,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.04400979,
							sizeY = 0.8775166,
							image = "huoban#zs",
						},
					},
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "wb4",
						varName = "friendDesc",
						posX = 0.5,
						posY = 0.9558175,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8534832,
						sizeY = 0.1346653,
						text = "填写邀请码或者邀请其他人填写自己的邀请码，均可获得如下奖励。",
						color = "FF7A5047",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "fa4",
						posX = 0.5258469,
						posY = 0.4579847,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.09458,
						sizeY = 0.885807,
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
							name = "bglb4",
							varName = "friend_scroll",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							horizontal = true,
							showScrollBar = false,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "yaoqing",
					varName = "invte_root",
					posX = 0.5,
					posY = 0.5011387,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8752496,
					sizeY = 0.8258766,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "bjt4",
						posX = 0.5,
						posY = 0.5542787,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.381168,
						sizeY = 1.244237,
						image = "hbdb#hbdb",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zs4",
							posX = 0.9678555,
							posY = 0.4682882,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.04400979,
							sizeY = 0.8775166,
							image = "huoban#zs",
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb1",
						posX = 0.2349294,
						posY = 0.9287686,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2088862,
						sizeY = 0.1346653,
						text = "我的积分：",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb2",
						varName = "integral_lay",
						posX = 0.4337092,
						posY = 0.9287686,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3663592,
						sizeY = 0.1346653,
						text = "55",
						color = "FF4C8E41",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "fa3",
						posX = 0.5258468,
						posY = 0.4579846,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.09458,
						sizeY = 0.885807,
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
							name = "bglb3",
							varName = "invte_scroll",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							horizontal = true,
							showScrollBar = false,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "fz",
						varName = "details_btn",
						posX = 0.5988998,
						posY = 0.9288238,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.03827198,
						sizeY = 0.06680467,
						image = "tong#tsf",
						imageNormal = "tong#tsf",
						disablePressScale = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb3",
						posX = 0.4804337,
						posY = 0.9287686,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2088862,
						sizeY = 0.1346653,
						text = "已邀请伙伴：",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wb5",
						varName = "invte_num",
						posX = 0.692724,
						posY = 0.9287686,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3663592,
						sizeY = 0.1346653,
						text = "10/10",
						color = "FF4C8E41",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "RichText",
						name = "wb8",
						varName = "inviteDesc",
						posX = 0.5572279,
						posY = 0.9871327,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8534832,
						sizeY = 0.1346653,
						text = "发送自己的邀请码给他人,他人提升等级后,自己可获得积分。",
						color = "FF966856",
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "main_btn",
					posX = 1.055602,
					posY = 0.7535144,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.08472906,
					sizeY = 0.1706897,
					image = "huoban#zy",
					imageNormal = "huoban#zy",
					imagePressed = "huoban#zy2",
					imageDisable = "huoban#zy",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xhd",
						varName = "main_red",
						posX = 0.9177928,
						posY = 0.7621897,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3139535,
						sizeY = 0.2828282,
						image = "zdte#hd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an6",
					varName = "friend_btn",
					posX = 1.055602,
					posY = 0.5665915,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08472906,
					sizeY = 0.1706897,
					image = "huoban#yq",
					imageNormal = "huoban#yq",
					imagePressed = "huoban#yq2",
					imageDisable = "huoban#yq",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xhd2",
						varName = "friend_red",
						posX = 0.9177928,
						posY = 0.7621897,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3139535,
						sizeY = 0.2828282,
						image = "zdte#hd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an7",
					varName = "invte_btn",
					posX = 1.055602,
					posY = 0.3831166,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08472906,
					sizeY = 0.1706897,
					image = "huoban#yql",
					imageNormal = "huoban#yql",
					imagePressed = "huoban#yql2",
					imageDisable = "huoban#yql",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "xhd3",
						varName = "invte_red",
						posX = 0.9177928,
						posY = 0.7621897,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3139535,
						sizeY = 0.2828282,
						image = "zdte#hd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 1.05458,
					posY = 0.9011098,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06600985,
					sizeY = 0.1310345,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
