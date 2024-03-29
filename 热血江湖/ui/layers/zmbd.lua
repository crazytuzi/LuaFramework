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
				sizeX = 0.7929688,
				sizeY = 0.8055556,
				image = "g#dt2.png",
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
					name = "hb1",
					posX = 0.3133006,
					posY = 0.7065418,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3534189,
					sizeY = 0.554502,
					image = "w#w_hua.png",
					alpha = 0.3,
					flippedX = true,
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hb2",
					posX = 0.6657102,
					posY = 0.7065418,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3534189,
					sizeY = 0.554502,
					image = "w#w_hua.png",
					alpha = 0.3,
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "pg",
					posX = 0.5,
					posY = 0.9561764,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9033602,
					sizeY = 0.065235,
					image = "w#cdd",
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "y2",
					posX = 0.9692256,
					posY = 0.02142051,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1339901,
					sizeY = 0.1706897,
					image = "w#w_yun.png",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "y1",
					posX = 0.03167748,
					posY = 0.961136,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1339901,
					sizeY = 0.1706897,
					image = "w#w_yun.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db1",
					posX = 0.5,
					posY = 0.629144,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8988064,
					sizeY = 0.4235358,
					image = "g#g_d9.png",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.9,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ha1",
					varName = "attack_army_btn",
					posX = 0.1646986,
					posY = 0.878345,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2019704,
					sizeY = 0.1344828,
					image = "w#w_aa4.png",
					imageNormal = "w#w_aa4.png",
					imagePressed = "w#w_aa2.png",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7630698,
						sizeY = 0.5408184,
						text = "进攻部队",
						color = "FFFBFFCC",
						fontSize = 26,
						fontOutlineEnable = true,
						fontOutlineColor = "FF51361C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xhd",
						varName = "attack_point",
						posX = 0.9334306,
						posY = 0.7559971,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09756099,
						sizeY = 0.2692307,
						image = "zdte#hd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ha2",
					varName = "defend_army_btn",
					posX = 0.3558274,
					posY = 0.878345,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2019704,
					sizeY = 0.1344828,
					image = "w#w_aa4.png",
					imageNormal = "w#w_aa4.png",
					imagePressed = "w#w_aa2.png",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7630698,
						sizeY = 0.5408184,
						text = "防守部队",
						color = "FFFBFFCC",
						fontSize = 26,
						fontOutlineEnable = true,
						fontOutlineColor = "FF51361C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xhd2",
						varName = "defend_point",
						posX = 0.9334306,
						posY = 0.7559971,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.09756099,
						sizeY = 0.2692307,
						image = "zdte#hd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dfk",
					posX = 0.5,
					posY = 0.6859792,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8999221,
					sizeY = 0.4822429,
					image = "4",
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
						name = "dw2",
						posX = 0.4099301,
						posY = 0.2170358,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7773487,
						sizeY = 0.3553189,
						image = "w#w_smd3.png",
						alpha = 0.5,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zjtx1",
						varName = "roleHeadBg",
						posX = 0.1060776,
						posY = 0.2899161,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1259003,
						sizeY = 0.3503743,
						image = "zdtx#txd.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "tx",
							varName = "my_icon",
							posX = 0.4986762,
							posY = 0.657466,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8443408,
							sizeY = 1.22449,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zjdjd",
							posX = 0.1737873,
							posY = 0.221748,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3652175,
							sizeY = 0.4387755,
							image = "zdte#djd2",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "zjdj",
								varName = "my_lvl",
								posX = 0.4111212,
								posY = 0.4604434,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7171876,
								sizeY = 0.8594346,
								text = "100",
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zjxt1",
							posX = 0.5380375,
							posY = 0.06732748,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8051196,
							sizeY = 0.1331301,
							image = "w#w_xdd.png",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "zjxd",
								posX = 0.5,
								posY = 0.45,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9201342,
								sizeY = 0.5839447,
								image = "w#w_xtd.png",
							},
							children = {
							{
								prop = {
									etype = "LoadingBar",
									name = "zjx",
									varName = "my_blood",
									posX = 0.5000001,
									posY = 0.55,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.965812,
									sizeY = 0.5833333,
									image = "w#w_xt.png",
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
						etype = "Image",
						name = "scd1",
						varName = "pet_root1",
						posX = 0.2704417,
						posY = 0.2255515,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txd1",
							posX = 0.4625,
							posY = 0.4712229,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7166085,
							sizeY = 0.8335562,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx1",
								varName = "pet_icon1",
								posX = 0.5,
								posY = 0.5451064,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.83,
								sizeY = 0.83,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "wk3",
								posX = 0.4580873,
								posY = 0.5515568,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9368423,
								sizeY = 0.8749999,
								image = "cl#sck",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx1",
							varName = "pet_star1",
							posX = 0.46875,
							posY = 0.1518916,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7255653,
							sizeY = 0.1729649,
							image = "scxx#scxx5.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "scdjd",
							posX = 0.150499,
							posY = 0.8088301,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2370296,
							sizeY = 0.2805708,
							image = "w#w_djd2.png",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "scdj",
								varName = "pet_lvl1",
								posX = 0.5,
								posY = 0.524541,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.263428,
								sizeY = 1.173865,
								text = "99",
								fontOutlineEnable = true,
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
						name = "scd2",
						varName = "pet_root2",
						posX = 0.3822383,
						posY = 0.2255515,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txd2",
							posX = 0.4625,
							posY = 0.4712229,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7166085,
							sizeY = 0.8335562,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx2",
								varName = "pet_icon2",
								posX = 0.5,
								posY = 0.5451064,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.83,
								sizeY = 0.83,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "wk4",
								posX = 0.4580873,
								posY = 0.5515568,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9368423,
								sizeY = 0.8749999,
								image = "cl#sck",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx2",
							varName = "pet_star2",
							posX = 0.46875,
							posY = 0.1518916,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7255653,
							sizeY = 0.1729649,
							image = "scxx#scxx5.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "scdjd2",
							posX = 0.150499,
							posY = 0.8088301,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2370296,
							sizeY = 0.2805708,
							image = "w#w_djd2.png",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "scdj2",
								varName = "pet_lvl2",
								posX = 0.4978018,
								posY = 0.524541,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.263428,
								sizeY = 1.173865,
								text = "99",
								fontOutlineEnable = true,
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
						name = "scd3",
						varName = "pet_root3",
						posX = 0.4940349,
						posY = 0.2255515,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txd3",
							posX = 0.4625,
							posY = 0.4712229,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7166085,
							sizeY = 0.8335562,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx3",
								varName = "pet_icon3",
								posX = 0.5,
								posY = 0.5451064,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.83,
								sizeY = 0.83,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "wk5",
								posX = 0.4580873,
								posY = 0.5515568,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9368423,
								sizeY = 0.8749999,
								image = "cl#sck",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx3",
							varName = "pet_star3",
							posX = 0.46875,
							posY = 0.1518916,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7255653,
							sizeY = 0.1729649,
							image = "scxx#scxx5.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "scdjd3",
							posX = 0.150499,
							posY = 0.8088301,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2370296,
							sizeY = 0.2805708,
							image = "w#w_djd2.png",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "scdj3",
								varName = "pet_lvl3",
								posX = 0.4978018,
								posY = 0.524541,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.263428,
								sizeY = 1.173865,
								text = "99",
								fontOutlineEnable = true,
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
						name = "scd4",
						varName = "pet_root4",
						posX = 0.6058315,
						posY = 0.2255515,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txd4",
							posX = 0.4625,
							posY = 0.4712229,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7166085,
							sizeY = 0.8335562,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx4",
								varName = "pet_icon4",
								posX = 0.5,
								posY = 0.5451064,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.83,
								sizeY = 0.83,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "wk6",
								posX = 0.4580873,
								posY = 0.5515568,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9368423,
								sizeY = 0.8749999,
								image = "cl#sck",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx4",
							varName = "pet_star4",
							posX = 0.46875,
							posY = 0.1518916,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7255653,
							sizeY = 0.1729649,
							image = "scxx#scxx5.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "scdjd4",
							posX = 0.150499,
							posY = 0.8088301,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2370296,
							sizeY = 0.2805708,
							image = "w#w_djd2.png",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "scdj4",
								varName = "pet_lvl4",
								posX = 0.4978018,
								posY = 0.524541,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.263428,
								sizeY = 1.173865,
								text = "99",
								fontOutlineEnable = true,
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
						name = "scd5",
						varName = "pet_root5",
						posX = 0.717628,
						posY = 0.2255515,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txd5",
							posX = 0.4625,
							posY = 0.4712229,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7166085,
							sizeY = 0.8335562,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx5",
								varName = "pet_icon5",
								posX = 0.5,
								posY = 0.5451064,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.83,
								sizeY = 0.83,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "wk7",
								posX = 0.4580873,
								posY = 0.5515568,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9368423,
								sizeY = 0.8749999,
								image = "cl#sck",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx5",
							varName = "pet_star5",
							posX = 0.46875,
							posY = 0.1518916,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7255653,
							sizeY = 0.1729649,
							image = "scxx#scxx5.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "scdjd5",
							posX = 0.150499,
							posY = 0.8088301,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2370296,
							sizeY = 0.2805708,
							image = "w#w_djd2.png",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "scdj5",
								varName = "pet_lvl5",
								posX = 0.4978018,
								posY = 0.524541,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.263428,
								sizeY = 1.173865,
								text = "99",
								fontOutlineEnable = true,
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
						name = "scd6",
						varName = "pet_root6",
						posX = 0.8294246,
						posY = 0.2255515,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txd6",
							posX = 0.4625,
							posY = 0.4712229,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7166085,
							sizeY = 0.8335562,
							image = "djk#ktong",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "tx6",
								varName = "pet_icon6",
								posX = 0.5,
								posY = 0.5451064,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.83,
								sizeY = 0.83,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "wk8",
								posX = 0.4580873,
								posY = 0.5515568,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9368423,
								sizeY = 0.8749999,
								image = "cl#sck",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xx6",
							varName = "pet_star6",
							posX = 0.46875,
							posY = 0.1518916,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7255653,
							sizeY = 0.1729649,
							image = "scxx#scxx5.png",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "scdjd6",
							posX = 0.150499,
							posY = 0.8088301,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2370296,
							sizeY = 0.2805708,
							image = "w#w_djd2.png",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "scdj6",
								varName = "pet_lvl6",
								posX = 0.4978018,
								posY = 0.524541,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.263428,
								sizeY = 1.173865,
								text = "99",
								fontOutlineEnable = true,
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
						name = "dw5",
						posX = 0.5394747,
						posY = 0.4828332,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.614988,
						sizeY = 0.1410926,
						image = "g#g_top4.png",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dw1",
							posX = 0.3079728,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.3874405,
							sizeY = 0.4932104,
							image = "w#w_zld.png",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dw3",
								posX = 0.5,
								posY = 0.6281725,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5034491,
								sizeY = 1.813768,
								image = "dw#zl",
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zmm7",
						varName = "my_power",
						posX = 0.6125477,
						posY = 0.4801503,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1844587,
						sizeY = 0.1858213,
						text = "99999",
						color = "FFFEDB45",
						fontSize = 24,
						fontOutlineColor = "FF00152E",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "smd",
						posX = 0.2339082,
						posY = 0.661431,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4206973,
						sizeY = 0.1663079,
						image = "zm#xdw",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "smdz",
							posX = 0.3841738,
							posY = 0.5429956,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6744559,
							sizeY = 0.8610234,
							text = "我方阵容：",
							color = "FF5AF6D3",
							fontSize = 24,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "ct",
						varName = "updata_btn",
						posX = 0.8984364,
						posY = 0.6614311,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1499856,
						sizeY = 0.1716119,
						image = "w#w_qq4.png",
						imageNormal = "w#w_qq4.png",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ctz",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7433098,
							sizeY = 0.81116,
							text = "调 整",
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
				{
					prop = {
						etype = "Image",
						name = "ksc1",
						varName = "n_root1",
						posX = 0.2704417,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd2.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "kt1",
							posX = 0.4551032,
							posY = 0.4869038,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6474743,
							sizeY = 0.6662209,
							image = "dw#dw_kong.png",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ksc2",
						varName = "n_root2",
						posX = 0.3822383,
						posY = 0.2255515,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd2.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "kt2",
							posX = 0.4551032,
							posY = 0.4869038,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6474743,
							sizeY = 0.6662209,
							image = "dw#dw_kong.png",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ksc3",
						varName = "n_root3",
						posX = 0.4940349,
						posY = 0.2255515,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd2.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "kt3",
							posX = 0.4551032,
							posY = 0.4869038,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6474743,
							sizeY = 0.6662209,
							image = "dw#dw_kong.png",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ksc4",
						varName = "n_root4",
						posX = 0.6058314,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd2.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "kt4",
							posX = 0.4551032,
							posY = 0.4869038,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6474743,
							sizeY = 0.6662209,
							image = "dw#dw_kong.png",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ksc5",
						varName = "n_root5",
						posX = 0.717628,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd2.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "kt5",
							posX = 0.4551032,
							posY = 0.4869038,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6474743,
							sizeY = 0.6662209,
							image = "dw#dw_kong.png",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ksc6",
						varName = "n_root6",
						posX = 0.8294246,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_txd2.png",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "kt6",
							posX = 0.4551032,
							posY = 0.4869038,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6474743,
							sizeY = 0.6662209,
							image = "dw#dw_kong.png",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ktx1",
						varName = "unlock_root4",
						posX = 0.6058314,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_suo.png",
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "xz1",
							varName = "lock_desc4",
							posX = 0.4475624,
							posY = 0.1899197,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8207237,
							sizeY = 0.4112223,
							text = "宗门10级",
							color = "FFE0E0E0",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ktx2",
						varName = "unlock_root5",
						posX = 0.717628,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_suo.png",
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "xz2",
							varName = "lock_desc5",
							posX = 0.4475624,
							posY = 0.1899197,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8207237,
							sizeY = 0.4112223,
							text = "宗门10级",
							color = "FFE0E0E0",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ktx3",
						varName = "unlock_root6",
						posX = 0.8294246,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_suo.png",
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "xz3",
							varName = "lock_desc6",
							posX = 0.4475624,
							posY = 0.1899197,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8207237,
							sizeY = 0.4112223,
							text = "宗门10级",
							color = "FFE0E0E0",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ktx4",
						varName = "unlock_root1",
						posX = 0.2704417,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_suo.png",
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "xz4",
							varName = "lock_desc1",
							posX = 0.4475624,
							posY = 0.1899197,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8207237,
							sizeY = 0.4112223,
							text = "宗门10级",
							color = "FFE0E0E0",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ktx5",
						varName = "unlock_root2",
						posX = 0.3822383,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_suo.png",
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "xz5",
							varName = "lock_desc2",
							posX = 0.4475624,
							posY = 0.1899197,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8207237,
							sizeY = 0.4112223,
							text = "宗门10级",
							color = "FFE0E0E0",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ktx6",
						varName = "unlock_root3",
						posX = 0.4940349,
						posY = 0.2255516,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1394267,
						sizeY = 0.3966862,
						image = "dw#dw_suo.png",
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "xz6",
							varName = "lock_desc3",
							posX = 0.4475624,
							posY = 0.1899197,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8207237,
							sizeY = 0.4112223,
							text = "宗门10级",
							color = "FFE0E0E0",
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
					name = "smd1",
					posX = 0.5,
					posY = 0.2601298,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8829358,
					sizeY = 0.1814205,
					image = "w#w_smd3.png",
					scale9 = true,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zs1",
						posX = 0.2964003,
						posY = 1.004556,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1272066,
						sizeY = 0.08553191,
						image = "w#w_zhuangshixian.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zs2",
						posX = 0.7070119,
						posY = 1.004556,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1272066,
						sizeY = 0.08553191,
						image = "w#w_zhuangshixian.png",
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "topz",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2722667,
						sizeY = 0.418156,
						image = "zm#jydzjc",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zmm",
						posX = 0.2179138,
						posY = 0.5323144,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1710806,
						sizeY = 0.457016,
						text = "伤害加成：",
						color = "FFC2F9E8",
						fontSize = 24,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zmm3",
						posX = 0.4150622,
						posY = 0.5323143,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1844587,
						sizeY = 0.4570158,
						text = "10%",
						color = "FF68F2CD",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zmm4",
						posX = 0.5811512,
						posY = 0.5323143,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.195724,
						sizeY = 0.4570158,
						text = "免伤加成：",
						color = "FFC2F9E8",
						fontSize = 24,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zmm5",
						posX = 0.800388,
						posY = 0.5323143,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2084585,
						sizeY = 0.4570158,
						text = "15%",
						color = "FF68F2CD",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gxin2",
					varName = "rule_btn",
					posX = 0.8585617,
					posY = 0.1034479,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1133005,
					sizeY = 0.07068966,
					image = "w#ww4",
					imageNormal = "w#ww4",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ctz2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7433098,
						sizeY = 0.81116,
						text = "规 则",
						color = "FFB0FFD9",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF145A4F",
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
					name = "zmm2",
					posX = 0.2891374,
					posY = 0.1068962,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4315591,
					sizeY = 0.117013,
					text = "精英弟子越多，属性加成越多",
					color = "FF459F86",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9817872,
					posY = 0.9699091,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.07684729,
					sizeY = 0.1362069,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.9001826,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3796875,
				sizeY = 0.08472222,
				image = "e#top2",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "td2",
					posX = 0.5,
					posY = 0.551724,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2798354,
					sizeY = 0.4918033,
					image = "zm#bdsd",
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
