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
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9695614,
						sizeY = 0.957048,
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
					name = "kk1",
					varName = "email_info",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9999999,
					sizeY = 0.9601052,
				},
				children = {
				{
					prop = {
						etype = "Grid",
						name = "fuyin",
						varName = "amuletNode",
						posX = 0.4862288,
						posY = 0.4991481,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4347529,
						sizeY = 0.7655395,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "fuyin1",
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
								name = "fuyin2",
								posX = 0.5011314,
								posY = 0.5187662,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.298512,
								sizeY = 1.245604,
								image = "zfsbj#fybj",
								scale9Left = 0.45,
								scale9Right = 0.45,
								scale9Top = 0.2,
								scale9Bottom = 0.7,
							},
							children = {
							{
								prop = {
									etype = "Image",
									name = "fy1",
									varName = "amuletBg1",
									posX = 0.2810874,
									posY = 0.7084824,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya1",
										varName = "amuletLock1",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb1",
										varName = "amuletBtn1",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc1",
										varName = "amuletIcon1",
										posX = 0.5,
										posY = 0.465971,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a10",
										varName = "stoneLevelBg1",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd10",
											varName = "stoneLevel1",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj1",
										varName = "stoneLight1",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy2",
									varName = "amuletBg2",
									posX = 0.2136046,
									posY = 0.5138696,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya2",
										varName = "amuletLock2",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										lockHV = true,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb2",
										varName = "amuletBtn2",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc2",
										varName = "amuletIcon2",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a11",
										varName = "stoneLevelBg2",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd11",
											varName = "stoneLevel2",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj2",
										varName = "stoneLight2",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy3",
									varName = "amuletBg3",
									posX = 0.3789187,
									posY = 0.5973035,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya3",
										varName = "amuletLock3",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb3",
										varName = "amuletBtn3",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc3",
										varName = "amuletIcon3",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a12",
										varName = "stoneLevelBg3",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd12",
											varName = "stoneLevel3",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj3",
										varName = "stoneLight3",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy4",
									varName = "amuletBg4",
									posX = 0.4940166,
									posY = 0.7187012,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya4",
										varName = "amuletLock4",
										posX = 0.518953,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb4",
										varName = "amuletBtn4",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc4",
										varName = "amuletIcon4",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a13",
										varName = "stoneLevelBg4",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd13",
											varName = "stoneLevel4",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj4",
										varName = "stoneLight4",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy5",
									varName = "amuletBg5",
									posX = 0.7085157,
									posY = 0.7088998,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya5",
										varName = "amuletLock5",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb5",
										varName = "amuletBtn5",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc5",
										varName = "amuletIcon5",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a14",
										varName = "stoneLevelBg5",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd14",
											varName = "stoneLevel5",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj5",
										varName = "stoneLight5",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy6",
									varName = "amuletBg6",
									posX = 0.6096662,
									posY = 0.5975659,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya6",
										varName = "amuletLock6",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb6",
										varName = "amuletBtn6",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc6",
										varName = "amuletIcon6",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a15",
										varName = "stoneLevelBg6",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd15",
											varName = "stoneLevel6",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj6",
										varName = "stoneLight6",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy7",
									varName = "amuletBg7",
									posX = 0.3771651,
									posY = 0.4306386,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya7",
										varName = "amuletLock7",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb7",
										varName = "amuletBtn7",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc7",
										varName = "amuletIcon7",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a16",
										varName = "stoneLevelBg7",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd16",
											varName = "stoneLevel7",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj7",
										varName = "stoneLight7",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy8",
									varName = "amuletBg8",
									posX = 0.494002,
									posY = 0.3324558,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya8",
										varName = "amuletLock8",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb8",
										varName = "amuletBtn8",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc8",
										varName = "amuletIcon8",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a17",
										varName = "stoneLevelBg8",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd17",
											varName = "stoneLevel8",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj8",
										varName = "stoneLight8",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy9",
									varName = "amuletBg9",
									posX = 0.2789251,
									posY = 0.3213335,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya9",
										varName = "amuletLock9",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb9",
										varName = "amuletBtn9",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc9",
										varName = "amuletIcon9",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a18",
										varName = "stoneLevelBg9",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd18",
											varName = "stoneLevel9",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj9",
										varName = "stoneLight9",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy10",
									varName = "amuletBg10",
									posX = 0.7742087,
									posY = 0.5147935,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya10",
										varName = "amuletLock10",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb10",
										varName = "amuletBtn10",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc10",
										varName = "amuletIcon10",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a19",
										varName = "stoneLevelBg10",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd19",
											varName = "stoneLevel10",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj10",
										varName = "stoneLight10",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy11",
									varName = "amuletBg11",
									posX = 0.7098312,
									posY = 0.3206943,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya11",
										varName = "amuletLock11",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb11",
										varName = "amuletBtn11",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc11",
										varName = "amuletIcon11",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a20",
										varName = "stoneLevelBg11",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd20",
											varName = "stoneLevel11",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj11",
										varName = "stoneLight11",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy12",
									varName = "amuletBg12",
									posX = 0.6117972,
									posY = 0.4329528,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya12",
										varName = "amuletLock12",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb12",
										varName = "amuletBtn12",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc12",
										varName = "amuletIcon12",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a21",
										varName = "stoneLevelBg12",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd21",
											varName = "stoneLevel12",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj12",
										varName = "stoneLight12",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy13",
									varName = "amuletBg13",
									posX = 0.1815874,
									posY = 0.6504824,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya13",
										varName = "amuletLock13",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb13",
										varName = "amuletBtn13",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc13",
										varName = "amuletIcon13",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a22",
										varName = "stoneLevelBg13",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd22",
											varName = "stoneLevel13",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj13",
										varName = "stoneLight13",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy14",
									varName = "amuletBg14",
									posX = 0.8085157,
									posY = 0.6454824,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya14",
										varName = "amuletLock14",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb14",
										varName = "amuletBtn14",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc14",
										varName = "amuletIcon14",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a23",
										varName = "stoneLevelBg14",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd23",
											varName = "stoneLevel14",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj14",
										varName = "stoneLight14",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy15",
									varName = "amuletBg15",
									posX = 0.1810874,
									posY = 0.3864824,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya15",
										varName = "amuletLock15",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb15",
										varName = "amuletBtn15",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc15",
										varName = "amuletIcon15",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a24",
										varName = "stoneLevelBg15",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd24",
											varName = "stoneLevel15",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj15",
										varName = "stoneLight15",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy16",
									varName = "amuletBg16",
									posX = 0.8085157,
									posY = 0.3864824,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya16",
										varName = "amuletLock16",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb16",
										varName = "amuletBtn16",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc16",
										varName = "amuletIcon16",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a25",
										varName = "stoneLevelBg16",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd25",
											varName = "stoneLevel16",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj16",
										varName = "stoneLight16",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
									},
								},
								},
							},
							{
								prop = {
									etype = "Image",
									name = "fy17",
									varName = "amuletBg17",
									posX = 0.495,
									posY = 0.52,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.0920807,
									sizeY = 0.09936383,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya17",
										varName = "amuletLock17",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7966079,
										sizeY = 0.7539329,
										image = "zfsbj#suo",
									},
								},
								{
									prop = {
										etype = "Button",
										name = "fyb17",
										varName = "amuletBtn17",
										posX = 0.4903868,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "fyc17",
										varName = "amuletIcon17",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1,
										sizeY = 1,
									},
								},
								{
									prop = {
										etype = "Image",
										name = "a26",
										varName = "stoneLevelBg17",
										posX = 0.5,
										posY = -0.2649973,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.53267,
										sizeY = 0.3787974,
										image = "zfsbj#tips",
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
											name = "qyd26",
											varName = "stoneLevel17",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.9359614,
											sizeY = 1.470972,
											text = "100",
											color = "FF65944D",
											fontSize = 18,
											hTextAlign = 1,
											vTextAlign = 1,
										},
									},
									},
								},
								{
									prop = {
										etype = "Image",
										name = "dj17",
										varName = "stoneLight17",
										posX = 0.4999991,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.340574,
										sizeY = 1.340575,
										image = "zfsbj#dianji",
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
							name = "wb1",
							varName = "desc",
							posX = 0.5,
							posY = 1.018562,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6936672,
							sizeY = 0.09344219,
							text = "多枚效果可以叠加",
							color = "FF65944D",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb3",
							varName = "stoneScroll",
							posX = 0.5,
							posY = 0.02928456,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8611426,
							sizeY = 0.2345771,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "g1",
						posX = 0.1463929,
						posY = 0.5125498,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2449189,
						sizeY = 0.9609604,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb1",
							varName = "groupScroll",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9659036,
							sizeY = 0.9309695,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "g2",
						posX = 0.8408182,
						posY = 0.5134453,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2704909,
						sizeY = 0.9627514,
						image = "b#d2",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb2",
							varName = "propertyScroll",
							posX = 0.5,
							posY = 0.5586603,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.98,
							sizeY = 0.8044686,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "you",
						varName = "rightBtn",
						posX = 0.9433,
						posY = 0.1000982,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04236453,
						sizeY = 0.09697213,
						image = "chu1#jiantou",
						imageNormal = "chu1#jiantou",
						disablePressScale = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dk",
						posX = 0.8403297,
						posY = 0.1020233,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.146798,
						sizeY = 0.08978901,
						image = "zfsbj#dt3",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "dk1",
							varName = "page",
							posX = 0.5133805,
							posY = 0.5000001,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9514606,
							sizeY = 0.9184899,
							text = "第一页yre",
							color = "FF966856",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "zuo",
						varName = "leftBtn",
						posX = 0.7372059,
						posY = 0.1000982,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04236453,
						sizeY = 0.09697213,
						image = "chu1#jiantou",
						imageNormal = "chu1#jiantou",
						disablePressScale = true,
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "yj",
						posX = 0.4827861,
						posY = 0.4982088,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4278674,
						sizeY = 0.8049836,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.9650654,
					posY = 0.9355491,
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
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8751824,
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
					name = "topz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#chakanyanjue",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "whh",
				varName = "helpBtn",
				posX = 0.9024606,
				posY = 0.2004933,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04765625,
				sizeY = 0.09166667,
				image = "tong#bz",
				effect = "helpBtn",
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
	gy337 = {
	},
	gy338 = {
	},
	gy339 = {
	},
	gy340 = {
	},
	gy341 = {
	},
	gy342 = {
	},
	gy343 = {
	},
	gy344 = {
	},
	gy345 = {
	},
	gy346 = {
	},
	gy347 = {
	},
	gy348 = {
	},
	gy349 = {
	},
	gy350 = {
	},
	gy351 = {
	},
	gy352 = {
	},
	gy353 = {
	},
	gy354 = {
	},
	gy355 = {
	},
	gy356 = {
	},
	gy357 = {
	},
	gy358 = {
	},
	gy359 = {
	},
	gy360 = {
	},
	gy361 = {
	},
	gy362 = {
	},
	gy363 = {
	},
	gy364 = {
	},
	gy365 = {
	},
	gy366 = {
	},
	gy367 = {
	},
	gy368 = {
	},
	gy369 = {
	},
	gy370 = {
	},
	gy371 = {
	},
	gy372 = {
	},
	gy373 = {
	},
	gy374 = {
	},
	gy375 = {
	},
	gy376 = {
	},
	gy377 = {
	},
	gy378 = {
	},
	gy379 = {
	},
	gy380 = {
	},
	gy381 = {
	},
	gy382 = {
	},
	gy383 = {
	},
	gy384 = {
	},
	gy385 = {
	},
	gy386 = {
	},
	gy387 = {
	},
	gy388 = {
	},
	gy389 = {
	},
	gy390 = {
	},
	gy391 = {
	},
	gy392 = {
	},
	gy393 = {
	},
	gy394 = {
	},
	gy395 = {
	},
	gy396 = {
	},
	gy397 = {
	},
	gy398 = {
	},
	gy399 = {
	},
	gy400 = {
	},
	gy401 = {
	},
	gy402 = {
	},
	gy403 = {
	},
	gy404 = {
	},
	gy405 = {
	},
	gy406 = {
	},
	gy407 = {
	},
	gy408 = {
	},
	gy409 = {
	},
	gy410 = {
	},
	gy411 = {
	},
	gy412 = {
	},
	gy413 = {
	},
	gy414 = {
	},
	gy415 = {
	},
	gy416 = {
	},
	gy417 = {
	},
	gy418 = {
	},
	gy419 = {
	},
	gy420 = {
	},
	gy421 = {
	},
	gy422 = {
	},
	gy423 = {
	},
	gy424 = {
	},
	gy425 = {
	},
	gy426 = {
	},
	gy427 = {
	},
	gy428 = {
	},
	gy429 = {
	},
	gy430 = {
	},
	gy431 = {
	},
	gy432 = {
	},
	gy433 = {
	},
	gy434 = {
	},
	gy435 = {
	},
	gy436 = {
	},
	gy437 = {
	},
	gy438 = {
	},
	gy439 = {
	},
	gy440 = {
	},
	gy441 = {
	},
	gy442 = {
	},
	gy443 = {
	},
	gy444 = {
	},
	gy445 = {
	},
	gy446 = {
	},
	gy447 = {
	},
	gy448 = {
	},
	gy449 = {
	},
	gy450 = {
	},
	gy451 = {
	},
	gy452 = {
	},
	gy453 = {
	},
	gy454 = {
	},
	gy455 = {
	},
	gy456 = {
	},
	gy457 = {
	},
	gy458 = {
	},
	gy459 = {
	},
	gy460 = {
	},
	gy461 = {
	},
	gy462 = {
	},
	gy463 = {
	},
	gy464 = {
	},
	gy465 = {
	},
	gy466 = {
	},
	gy467 = {
	},
	gy468 = {
	},
	gy469 = {
	},
	gy470 = {
	},
	gy471 = {
	},
	gy472 = {
	},
	gy473 = {
	},
	gy474 = {
	},
	gy475 = {
	},
	gy476 = {
	},
	gy477 = {
	},
	gy478 = {
	},
	gy479 = {
	},
	gy480 = {
	},
	gy481 = {
	},
	gy482 = {
	},
	gy483 = {
	},
	gy484 = {
	},
	gy485 = {
	},
	gy486 = {
	},
	gy487 = {
	},
	gy488 = {
	},
	gy489 = {
	},
	gy490 = {
	},
	gy491 = {
	},
	gy492 = {
	},
	gy493 = {
	},
	gy494 = {
	},
	gy495 = {
	},
	gy496 = {
	},
	gy497 = {
	},
	gy498 = {
	},
	gy499 = {
	},
	gy500 = {
	},
	gy501 = {
	},
	gy502 = {
	},
	gy503 = {
	},
	gy504 = {
	},
	gy505 = {
	},
	gy506 = {
	},
	gy507 = {
	},
	gy508 = {
	},
	gy509 = {
	},
	gy510 = {
	},
	gy511 = {
	},
	gy512 = {
	},
	gy513 = {
	},
	gy514 = {
	},
	gy515 = {
	},
	gy516 = {
	},
	gy517 = {
	},
	gy518 = {
	},
	gy519 = {
	},
	gy520 = {
	},
	gy521 = {
	},
	gy522 = {
	},
	gy523 = {
	},
	gy524 = {
	},
	gy525 = {
	},
	gy526 = {
	},
	gy527 = {
	},
	gy528 = {
	},
	gy529 = {
	},
	gy530 = {
	},
	gy531 = {
	},
	gy532 = {
	},
	gy533 = {
	},
	gy534 = {
	},
	gy535 = {
	},
	gy536 = {
	},
	gy537 = {
	},
	gy538 = {
	},
	gy539 = {
	},
	gy540 = {
	},
	gy541 = {
	},
	gy542 = {
	},
	gy543 = {
	},
	gy544 = {
	},
	gy545 = {
	},
	gy546 = {
	},
	gy547 = {
	},
	gy548 = {
	},
	gy549 = {
	},
	gy550 = {
	},
	gy551 = {
	},
	gy552 = {
	},
	gy553 = {
	},
	gy554 = {
	},
	gy555 = {
	},
	gy556 = {
	},
	gy557 = {
	},
	gy558 = {
	},
	gy559 = {
	},
	gy560 = {
	},
	gy561 = {
	},
	gy562 = {
	},
	gy563 = {
	},
	gy564 = {
	},
	gy565 = {
	},
	gy566 = {
	},
	gy567 = {
	},
	gy568 = {
	},
	gy569 = {
	},
	gy570 = {
	},
	gy571 = {
	},
	gy572 = {
	},
	gy573 = {
	},
	gy574 = {
	},
	gy575 = {
	},
	gy576 = {
	},
	gy577 = {
	},
	gy578 = {
	},
	gy579 = {
	},
	gy580 = {
	},
	gy581 = {
	},
	gy582 = {
	},
	gy583 = {
	},
	gy584 = {
	},
	gy585 = {
	},
	gy586 = {
	},
	gy587 = {
	},
	gy588 = {
	},
	gy589 = {
	},
	gy590 = {
	},
	gy591 = {
	},
	gy592 = {
	},
	gy593 = {
	},
	gy594 = {
	},
	gy595 = {
	},
	gy596 = {
	},
	gy597 = {
	},
	gy598 = {
	},
	gy599 = {
	},
	gy600 = {
	},
	gy601 = {
	},
	gy602 = {
	},
	gy603 = {
	},
	gy604 = {
	},
	gy605 = {
	},
	gy606 = {
	},
	gy607 = {
	},
	gy608 = {
	},
	gy609 = {
	},
	gy610 = {
	},
	gy611 = {
	},
	gy612 = {
	},
	gy613 = {
	},
	gy614 = {
	},
	gy615 = {
	},
	gy616 = {
	},
	gy617 = {
	},
	gy618 = {
	},
	gy619 = {
	},
	gy620 = {
	},
	gy621 = {
	},
	gy622 = {
	},
	gy623 = {
	},
	gy624 = {
	},
	gy625 = {
	},
	gy626 = {
	},
	gy627 = {
	},
	gy628 = {
	},
	gy629 = {
	},
	gy630 = {
	},
	gy631 = {
	},
	gy632 = {
	},
	gy633 = {
	},
	gy634 = {
	},
	gy635 = {
	},
	gy636 = {
	},
	gy637 = {
	},
	gy638 = {
	},
	gy639 = {
	},
	gy640 = {
	},
	gy641 = {
	},
	gy642 = {
	},
	gy643 = {
	},
	gy644 = {
	},
	gy645 = {
	},
	gy646 = {
	},
	gy647 = {
	},
	gy648 = {
	},
	gy649 = {
	},
	gy650 = {
	},
	gy651 = {
	},
	gy652 = {
	},
	gy653 = {
	},
	gy654 = {
	},
	gy655 = {
	},
	gy656 = {
	},
	gy657 = {
	},
	gy658 = {
	},
	gy659 = {
	},
	gy660 = {
	},
	gy661 = {
	},
	gy662 = {
	},
	gy663 = {
	},
	gy664 = {
	},
	gy665 = {
	},
	gy666 = {
	},
	gy667 = {
	},
	gy668 = {
	},
	gy669 = {
	},
	gy670 = {
	},
	gy671 = {
	},
	gy672 = {
	},
	gy673 = {
	},
	gy674 = {
	},
	gy675 = {
	},
	gy676 = {
	},
	gy677 = {
	},
	gy678 = {
	},
	gy679 = {
	},
	gy680 = {
	},
	gy681 = {
	},
	gy682 = {
	},
	gy683 = {
	},
	gy684 = {
	},
	gy685 = {
	},
	gy686 = {
	},
	gy687 = {
	},
	gy688 = {
	},
	gy689 = {
	},
	gy690 = {
	},
	gy691 = {
	},
	gy692 = {
	},
	gy693 = {
	},
	gy694 = {
	},
	gy695 = {
	},
	gy696 = {
	},
	gy697 = {
	},
	gy698 = {
	},
	gy699 = {
	},
	gy700 = {
	},
	gy701 = {
	},
	gy702 = {
	},
	gy703 = {
	},
	gy704 = {
	},
	gy705 = {
	},
	gy706 = {
	},
	gy707 = {
	},
	gy708 = {
	},
	gy709 = {
	},
	gy710 = {
	},
	gy711 = {
	},
	gy712 = {
	},
	gy713 = {
	},
	gy714 = {
	},
	gy715 = {
	},
	gy716 = {
	},
	gy717 = {
	},
	gy718 = {
	},
	gy719 = {
	},
	gy720 = {
	},
	gy721 = {
	},
	gy722 = {
	},
	gy723 = {
	},
	gy724 = {
	},
	gy725 = {
	},
	gy726 = {
	},
	gy727 = {
	},
	gy728 = {
	},
	gy729 = {
	},
	gy730 = {
	},
	gy731 = {
	},
	gy732 = {
	},
	gy733 = {
	},
	gy734 = {
	},
	gy735 = {
	},
	gy736 = {
	},
	gy737 = {
	},
	gy738 = {
	},
	gy739 = {
	},
	gy740 = {
	},
	gy741 = {
	},
	gy742 = {
	},
	gy743 = {
	},
	gy744 = {
	},
	gy745 = {
	},
	gy746 = {
	},
	gy747 = {
	},
	gy748 = {
	},
	gy749 = {
	},
	gy750 = {
	},
	gy751 = {
	},
	gy752 = {
	},
	gy753 = {
	},
	gy754 = {
	},
	gy755 = {
	},
	gy756 = {
	},
	gy757 = {
	},
	gy758 = {
	},
	gy759 = {
	},
	gy760 = {
	},
	gy761 = {
	},
	gy762 = {
	},
	gy763 = {
	},
	gy764 = {
	},
	gy765 = {
	},
	gy766 = {
	},
	gy767 = {
	},
	gy768 = {
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
