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
				posX = 0.5007802,
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
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
					name = "kk2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
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
						posX = 0.4844976,
						posY = 0.4921793,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9363168,
						sizeY = 0.959002,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "grkp",
					varName = "personRoot",
					posX = 0.4990037,
					posY = 0.4757447,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9940227,
					sizeY = 0.9234368,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dt1",
						posX = 0.4844805,
						posY = 0.4688257,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.903978,
						sizeY = 0.8357344,
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
							name = "tp2",
							posX = 0.7815332,
							posY = 0.4965976,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.01642018,
							sizeY = 0.9969906,
							image = "sblz#fgx",
							flippedX = true,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "tp3",
							posX = 0.877937,
							posY = 0.5750859,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2272595,
							sizeY = 0.7125252,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb1",
							varName = "scrollCard",
							posX = 0.3814464,
							posY = 0.501874,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7640516,
							sizeY = 0.8787789,
							horizontal = true,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "a1",
							varName = "activationBtn",
							posX = 0.1136997,
							posY = 1.080406,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1688498,
							sizeY = 0.129576,
							image = "chu1#fy1",
							imageNormal = "chu1#fy1",
							imagePressed = "chu1#fy2",
							imageDisable = "chu1#fy1",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "w1",
								posX = 0.5035937,
								posY = 0.5270259,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9205694,
								sizeY = 0.7401523,
								text = "已启动",
								color = "FF966856",
								fontSize = 24,
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
							name = "a2",
							varName = "bagBtn",
							posX = 0.2977649,
							posY = 1.080406,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1688498,
							sizeY = 0.129576,
							image = "chu1#fy1",
							imageNormal = "chu1#fy1",
							imagePressed = "chu1#fy2",
							imageDisable = "chu1#fy1",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "w2",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9205694,
								sizeY = 0.7401523,
								text = "我的卡包",
								color = "FF966856",
								fontSize = 24,
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
							name = "a3",
							varName = "ok",
							posX = 0.890079,
							posY = 0.1390265,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1348605,
							sizeY = 0.129576,
							image = "chu1#an3",
							imageNormal = "chu1#an3",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "w9",
								varName = "okText",
								posX = 0.5174324,
								posY = 0.565231,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.89508,
								sizeY = 0.7260849,
								text = "启动",
								fontSize = 24,
								fontOutlineEnable = true,
								fontOutlineColor = "FF2A6953",
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "aa",
							varName = "selectGradeRoot",
							posX = 0.5043463,
							posY = 1.080406,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1820069,
							sizeY = 0.1072353,
							image = "b#srk",
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "a4",
								varName = "gradeBtn",
								posX = 0.4832061,
								posY = 0.4614069,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
							},
							children = {
							{
								prop = {
									etype = "Button",
									name = "a5",
									varName = "filterBtn",
									posX = 0.8618802,
									posY = 0.5288775,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.2590362,
									sizeY = 0.9166667,
									image = "pmh#jiantou",
									imageNormal = "pmh#jiantou",
								},
							},
							},
						},
						{
							prop = {
								etype = "Label",
								name = "w10",
								varName = "gradeLabel",
								posX = 0.379713,
								posY = 0.5098193,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.661248,
								sizeY = 0.705739,
								text = "筛选",
								color = "FFFFF0D5",
								fontSize = 24,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "d2",
							varName = "levelRoot",
							posX = 0.5044779,
							posY = 1.027309,
							anchorX = 0.5,
							anchorY = 1,
							visible = false,
							sizeX = 0.1679427,
							sizeY = 0.5466393,
							image = "b#bp",
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
								name = "d3",
								posX = 0.5060153,
								posY = 0.5008197,
								anchorX = 0.5,
								anchorY = 0.5,
								visible = false,
								sizeX = 0.9863335,
								sizeY = 0.9884448,
								image = "b#bp",
								scale9Left = 0.45,
								scale9Right = 0.45,
								scale9Top = 0.45,
								scale9Bottom = 0.45,
							},
						},
						{
							prop = {
								etype = "Scroll",
								name = "lb2",
								varName = "filterScroll",
								posX = 0.4939878,
								posY = 0.4991664,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9863335,
								sizeY = 0.9884449,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "j1",
							posX = 0.8676583,
							posY = 0.5086963,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3372772,
							sizeY = 0.6270615,
						},
						children = {
						{
							prop = {
								etype = "Scroll",
								name = "ld5",
								varName = "scrollDesc1",
								posX = 0.5610822,
								posY = 0.6082757,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5971719,
								sizeY = 1.198681,
							},
						},
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "text1",
							varName = "useCount",
							posX = 0.8345946,
							posY = 1.074927,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2999288,
							sizeY = 0.08894518,
							text = "当前已获得卡片",
							color = "FF966856",
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "text2",
							varName = "descTip",
							posX = 0.4922073,
							posY = 0.03696411,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5652327,
							sizeY = 0.07334378,
							color = "FF966856",
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
					etype = "Grid",
					name = "bpkp",
					varName = "factionRoot",
					posX = 0.4990037,
					posY = 0.4757447,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9940227,
					sizeY = 0.9234368,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dt2",
						posX = 0.4844805,
						posY = 0.5257778,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9039779,
						sizeY = 0.9496387,
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
							name = "tp4",
							posX = 0.7815332,
							posY = 0.4370333,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.01642018,
							sizeY = 0.8774067,
							image = "sblz#fgx",
							flippedX = true,
							flippedY = true,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "tp5",
							posX = 0.8626083,
							posY = 0.8690991,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1881768,
							sizeY = 0.06516229,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "w11",
								posX = 0.8182585,
								posY = 0.8736051,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.2888725,
								sizeY = 0.1246913,
								color = "FF966856",
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "RichText",
								name = "ww1",
								varName = "a2",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
								color = "FFFFF0D5",
								fontOutlineEnable = true,
								fontOutlineColor = "FFA47848",
								fontOutlineSize = 2,
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Image",
								name = "j2",
								posX = 0.5268362,
								posY = -5.96721,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.792342,
								sizeY = 8.468835,
							},
							children = {
							{
								prop = {
									etype = "Scroll",
									name = "lb6",
									varName = "scrollDesc2",
									posX = 0.5610827,
									posY = 0.6082757,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.597172,
									sizeY = 1.198681,
								},
							},
							},
						},
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb3",
							varName = "scrollFaction",
							posX = 0.3814464,
							posY = 0.4416769,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7640517,
							sizeY = 0.7733738,
							horizontal = true,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "a6",
							varName = "factionGetBtn",
							posX = 0.8900791,
							posY = 0.122351,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1459392,
							sizeY = 0.1125997,
							image = "chu1#an2",
							imageNormal = "chu1#an2",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "dt3",
								posX = 0.4601758,
								posY = 0.5675347,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9352455,
								sizeY = 0.7563444,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "w17",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9352455,
								sizeY = 0.8432993,
								text = "领 取",
								fontSize = 24,
								fontOutlineEnable = true,
								fontOutlineColor = "FF2A6953",
								hTextAlign = 1,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "ww",
							varName = "getDesc",
							posX = 0.890079,
							posY = 0.04218492,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2635432,
							sizeY = 0.1038795,
							text = "今日已领取",
							color = "FFA47848",
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
					etype = "Grid",
					name = "kprz",
					varName = "logRoot",
					posX = 0.4990037,
					posY = 0.4757447,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9940227,
					sizeY = 0.9234368,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "bpxx",
						posX = 0.4844805,
						posY = 0.4688257,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.903978,
						sizeY = 0.8357344,
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
							etype = "Scroll",
							name = "lb4",
							varName = "scrollLog",
							posX = 0.5010383,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9943518,
							sizeY = 0.9728252,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "a11",
							varName = "personalLog",
							posX = 0.1136997,
							posY = 1.080406,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1688498,
							sizeY = 0.129576,
							image = "chu1#fy1",
							imageNormal = "chu1#fy1",
							imagePressed = "chu1#fy2",
							imageDisable = "chu1#fy1",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "wb",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9335301,
								sizeY = 0.7745846,
								text = "我的日志",
								color = "FF966856",
								fontSize = 24,
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
							name = "a12",
							varName = "warZoneLog",
							posX = 0.2977649,
							posY = 1.080406,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1688498,
							sizeY = 0.129576,
							image = "chu1#fy1",
							imageNormal = "chu1#fy1",
							imagePressed = "chu1#fy2",
							imageDisable = "chu1#fy1",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "wb1",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9335302,
								sizeY = 0.7745846,
								text = "战区日志",
								color = "FF966856",
								fontSize = 24,
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
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.9920635,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.24,
					sizeY = 0.08253969,
					image = "chu1#top",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tt",
						varName = "title_name",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5151515,
						sizeY = 0.4807692,
						image = "biaoti#smkp",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "can1",
				varName = "personRootBtn",
				posX = 0.8722209,
				posY = 0.686524,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07734375,
				sizeY = 0.2125,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "caz1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2861022,
					sizeY = 0.809434,
					text = "个人卡",
					color = "FFEBC6B4",
					fontSize = 22,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
					lineSpaceAdd = -2,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd4",
					varName = "personal_red",
					posX = 0.7694741,
					posY = 0.7978233,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2727273,
					sizeY = 0.1830065,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "can2",
				varName = "factionRootBtn",
				posX = 0.8722209,
				posY = 0.5217844,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07734375,
				sizeY = 0.2125,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "caz3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2861022,
					sizeY = 0.809434,
					text = "帮派卡",
					color = "FFEBC6B4",
					fontSize = 22,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
					lineSpaceAdd = -2,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd3",
					varName = "faction_red",
					posX = 0.7694741,
					posY = 0.7978233,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					lockHV = true,
					sizeX = 0.2727273,
					sizeY = 0.1830065,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "can3",
				varName = "logRootBtn",
				posX = 0.8722209,
				posY = 0.3570448,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07734375,
				sizeY = 0.2125,
				image = "tong#yq1",
				imageNormal = "tong#yq1",
				imagePressed = "chu1#yq2",
				imageDisable = "tong#yq1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "caz2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2861022,
					sizeY = 0.809434,
					text = "日志",
					color = "FFEBC6B4",
					fontSize = 22,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
					lineSpaceAdd = -2,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.8695784,
				posY = 0.8302639,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a10",
				varName = "help",
				posX = 0.8767231,
				posY = 0.1935604,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04765625,
				sizeY = 0.09166667,
				image = "tong#bz",
				imageNormal = "tong#bz",
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
	gy55 = {
	},
	gy56 = {
	},
	gy57 = {
	},
	gy58 = {
	},
	gy59 = {
	},
	gy60 = {
	},
	gy61 = {
	},
	gy62 = {
	},
	gy63 = {
	},
	gy64 = {
	},
	gy65 = {
	},
	gy66 = {
	},
	gy67 = {
	},
	gy68 = {
	},
	gy69 = {
	},
	gy70 = {
	},
	gy71 = {
	},
	gy72 = {
	},
	gy73 = {
	},
	gy74 = {
	},
	gy75 = {
	},
	gy76 = {
	},
	gy77 = {
	},
	gy78 = {
	},
	gy79 = {
	},
	gy80 = {
	},
	gy81 = {
	},
	gy82 = {
	},
	gy83 = {
	},
	gy84 = {
	},
	gy85 = {
	},
	gy86 = {
	},
	gy87 = {
	},
	gy88 = {
	},
	gy89 = {
	},
	gy90 = {
	},
	gy91 = {
	},
	gy92 = {
	},
	gy93 = {
	},
	gy94 = {
	},
	gy95 = {
	},
	gy96 = {
	},
	gy97 = {
	},
	gy98 = {
	},
	gy99 = {
	},
	gy100 = {
	},
	gy101 = {
	},
	gy102 = {
	},
	gy103 = {
	},
	gy104 = {
	},
	gy105 = {
	},
	gy106 = {
	},
	gy107 = {
	},
	gy108 = {
	},
	gy109 = {
	},
	gy110 = {
	},
	gy111 = {
	},
	gy112 = {
	},
	gy113 = {
	},
	gy114 = {
	},
	gy115 = {
	},
	gy116 = {
	},
	gy117 = {
	},
	gy118 = {
	},
	gy119 = {
	},
	gy120 = {
	},
	gy121 = {
	},
	gy122 = {
	},
	gy123 = {
	},
	gy124 = {
	},
	gy125 = {
	},
	gy126 = {
	},
	gy127 = {
	},
	gy128 = {
	},
	gy129 = {
	},
	gy130 = {
	},
	gy131 = {
	},
	gy132 = {
	},
	gy133 = {
	},
	gy134 = {
	},
	gy135 = {
	},
	gy136 = {
	},
	gy137 = {
	},
	gy138 = {
	},
	gy139 = {
	},
	gy140 = {
	},
	gy141 = {
	},
	gy142 = {
	},
	gy143 = {
	},
	gy144 = {
	},
	gy145 = {
	},
	gy146 = {
	},
	gy147 = {
	},
	gy148 = {
	},
	gy149 = {
	},
	gy150 = {
	},
	gy151 = {
	},
	gy152 = {
	},
	gy153 = {
	},
	gy154 = {
	},
	gy155 = {
	},
	gy156 = {
	},
	gy157 = {
	},
	gy158 = {
	},
	gy159 = {
	},
	gy160 = {
	},
	gy161 = {
	},
	gy162 = {
	},
	gy163 = {
	},
	gy164 = {
	},
	gy165 = {
	},
	gy166 = {
	},
	gy167 = {
	},
	gy168 = {
	},
	gy169 = {
	},
	gy170 = {
	},
	gy171 = {
	},
	gy172 = {
	},
	gy173 = {
	},
	gy174 = {
	},
	gy175 = {
	},
	gy176 = {
	},
	gy177 = {
	},
	gy178 = {
	},
	gy179 = {
	},
	gy180 = {
	},
	gy181 = {
	},
	gy182 = {
	},
	gy183 = {
	},
	gy184 = {
	},
	gy185 = {
	},
	gy186 = {
	},
	gy187 = {
	},
	gy188 = {
	},
	gy189 = {
	},
	gy190 = {
	},
	gy191 = {
	},
	gy192 = {
	},
	gy193 = {
	},
	gy194 = {
	},
	gy195 = {
	},
	gy196 = {
	},
	gy197 = {
	},
	gy198 = {
	},
	gy199 = {
	},
	gy200 = {
	},
	gy201 = {
	},
	gy202 = {
	},
	gy203 = {
	},
	gy204 = {
	},
	gy205 = {
	},
	gy206 = {
	},
	gy207 = {
	},
	gy208 = {
	},
	gy209 = {
	},
	gy210 = {
	},
	gy211 = {
	},
	gy212 = {
	},
	gy213 = {
	},
	gy214 = {
	},
	gy215 = {
	},
	gy216 = {
	},
	gy217 = {
	},
	gy218 = {
	},
	gy219 = {
	},
	gy220 = {
	},
	gy221 = {
	},
	gy222 = {
	},
	gy223 = {
	},
	gy224 = {
	},
	gy225 = {
	},
	gy226 = {
	},
	gy227 = {
	},
	gy228 = {
	},
	gy229 = {
	},
	gy230 = {
	},
	gy231 = {
	},
	gy232 = {
	},
	gy233 = {
	},
	gy234 = {
	},
	gy235 = {
	},
	gy236 = {
	},
	gy237 = {
	},
	gy238 = {
	},
	gy239 = {
	},
	gy240 = {
	},
	gy241 = {
	},
	gy242 = {
	},
	gy243 = {
	},
	gy244 = {
	},
	gy245 = {
	},
	gy246 = {
	},
	gy247 = {
	},
	gy248 = {
	},
	gy249 = {
	},
	gy250 = {
	},
	gy251 = {
	},
	gy252 = {
	},
	gy253 = {
	},
	gy254 = {
	},
	gy255 = {
	},
	gy256 = {
	},
	gy257 = {
	},
	gy258 = {
	},
	gy259 = {
	},
	gy260 = {
	},
	gy261 = {
	},
	gy262 = {
	},
	gy263 = {
	},
	gy264 = {
	},
	gy265 = {
	},
	gy266 = {
	},
	gy267 = {
	},
	gy268 = {
	},
	gy269 = {
	},
	gy270 = {
	},
	gy271 = {
	},
	gy272 = {
	},
	gy273 = {
	},
	gy274 = {
	},
	gy275 = {
	},
	gy276 = {
	},
	gy277 = {
	},
	gy278 = {
	},
	gy279 = {
	},
	gy280 = {
	},
	gy281 = {
	},
	gy282 = {
	},
	gy283 = {
	},
	gy284 = {
	},
	gy285 = {
	},
	gy286 = {
	},
	gy287 = {
	},
	gy288 = {
	},
	gy289 = {
	},
	gy290 = {
	},
	gy291 = {
	},
	gy292 = {
	},
	gy293 = {
	},
	gy294 = {
	},
	gy295 = {
	},
	gy296 = {
	},
	gy297 = {
	},
	gy298 = {
	},
	gy299 = {
	},
	gy300 = {
	},
	gy301 = {
	},
	gy302 = {
	},
	gy303 = {
	},
	gy304 = {
	},
	gy305 = {
	},
	gy306 = {
	},
	gy307 = {
	},
	gy308 = {
	},
	gy309 = {
	},
	gy310 = {
	},
	gy311 = {
	},
	gy312 = {
	},
	gy313 = {
	},
	gy314 = {
	},
	gy315 = {
	},
	gy316 = {
	},
	gy317 = {
	},
	gy318 = {
	},
	gy319 = {
	},
	gy320 = {
	},
	gy321 = {
	},
	gy322 = {
	},
	gy323 = {
	},
	gy324 = {
	},
	gy325 = {
	},
	gy326 = {
	},
	gy327 = {
	},
	gy328 = {
	},
	gy329 = {
	},
	gy330 = {
	},
	gy331 = {
	},
	gy332 = {
	},
	gy333 = {
	},
	gy334 = {
	},
	gy335 = {
	},
	gy336 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
