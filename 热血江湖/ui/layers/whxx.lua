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
				name = "dt2",
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
						posX = 0.4822664,
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
					etype = "Image",
					name = "sx",
					posX = 0.7532454,
					posY = 0.5000054,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3491735,
					sizeY = 0.8812994,
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
						name = "lie",
						varName = "propScroll",
						posX = 0.5000001,
						posY = 0.5000001,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.98,
						sizeY = 0.98,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
					posX = 0.9653688,
					posY = 0.9336147,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06600985,
					sizeY = 0.1310345,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "z1",
					posX = 0.3067296,
					posY = 0.5275151,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.6186191,
					sizeY = 0.9768039,
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
						name = "dw1",
						posX = 0.507619,
						posY = 0.465036,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.949738,
						sizeY = 0.9712839,
						image = "whbj#whbj",
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "zldd",
							posX = 0.2298788,
							posY = 0.08969384,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3655639,
							sizeY = 0.09268055,
							image = "wh#top",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "zl",
								varName = "battle_power",
								posX = 0.5796539,
								posY = 0.4608635,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7138616,
								sizeY = 1.061954,
								text = "999999",
								color = "FFFFE7AF",
								fontSize = 22,
								fontOutlineEnable = true,
								fontOutlineColor = "FFB2722C",
								fontOutlineSize = 2,
								hTextAlign = 1,
								vTextAlign = 1,
								colorTL = "FFFFD060",
								colorTR = "FFFFD060",
								colorBR = "FFF2441C",
								colorBL = "FFF2441C",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "zhanz",
								posX = 0.2747681,
								posY = 0.4455239,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1605504,
								sizeY = 0.627451,
								image = "tong#zl",
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zldd2",
							posX = 0.7388186,
							posY = 0.08969384,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3655639,
							sizeY = 0.09268055,
							image = "wh#top",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "zl2",
								varName = "gradeDesc",
								posX = 0.6209386,
								posY = 0.4412556,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7138616,
								sizeY = 1.061954,
								text = "境界",
								color = "FFFFD974",
								fontSize = 22,
								fontOutlineColor = "FFB2722C",
								fontOutlineSize = 2,
								hTextAlign = 1,
								vTextAlign = 1,
								colorTL = "FFFFD060",
								colorTR = "FFFFD060",
								colorBR = "FFF2441C",
								colorBL = "FFF2441C",
							},
						},
						{
							prop = {
								etype = "Label",
								name = "zl3",
								posX = 0.3411227,
								posY = 0.4412556,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.7138616,
								sizeY = 1.061954,
								text = "归元",
								color = "FFFF9642",
								fontSize = 22,
								fontOutlineEnable = true,
								fontOutlineColor = "FF713112",
								hTextAlign = 1,
								vTextAlign = 1,
								colorTL = "FFFFD060",
								colorTR = "FFFFD060",
								colorBR = "FFF2441C",
								colorBL = "FFF2441C",
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "zb1",
						varName = "part1Btn",
						posX = 0.3851262,
						posY = 0.8280987,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1434456,
						sizeY = 0.1531827,
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xzt1",
							varName = "is_select1",
							posX = 0.5,
							posY = 0.4669177,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 1.319149,
							sizeY = 1.367383,
							image = "wh#xz",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pjd1",
							varName = "partIcon1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9042551,
							sizeY = 0.9373192,
							image = "wh#qian",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qhz1",
							varName = "partLvl1",
							posX = 0.1601112,
							posY = 0.8365986,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8872787,
							sizeY = 0.3761843,
							text = "11",
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
						name = "zb2",
						varName = "part2Btn",
						posX = 0.6304116,
						posY = 0.8280987,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1434456,
						sizeY = 0.1531827,
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xzt2",
							varName = "is_select2",
							posX = 0.5,
							posY = 0.4669177,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 1.319149,
							sizeY = 1.367383,
							image = "wh#xz",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pjd2",
							varName = "partIcon2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9042551,
							sizeY = 0.9373192,
							image = "wh#kun",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qhz2",
							varName = "partLvl2",
							posX = 0.1601112,
							posY = 0.8365986,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8872787,
							sizeY = 0.3761843,
							text = "11",
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
						name = "zb3",
						varName = "part3Btn",
						posX = 0.7980044,
						posY = 0.639231,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1434456,
						sizeY = 0.1531827,
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xzt3",
							varName = "is_select3",
							posX = 0.5,
							posY = 0.4669177,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 1.319149,
							sizeY = 1.367383,
							image = "wh#xz",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pjd3",
							varName = "partIcon3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9042551,
							sizeY = 0.9373192,
							image = "wh#li",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qhz3",
							varName = "partLvl3",
							posX = 0.1601112,
							posY = 0.8365986,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8872787,
							sizeY = 0.3761843,
							text = "11",
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
						name = "zb4",
						varName = "part4Btn",
						posX = 0.7980018,
						posY = 0.381191,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1434456,
						sizeY = 0.1531827,
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xzt4",
							varName = "is_select4",
							posX = 0.5,
							posY = 0.4669177,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 1.319149,
							sizeY = 1.367383,
							image = "wh#xz",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pjd4",
							varName = "partIcon4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9042551,
							sizeY = 0.9373192,
							image = "wh#kan",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qhz4",
							varName = "partLvl4",
							posX = 0.1601112,
							posY = 0.8365986,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8872787,
							sizeY = 0.3761843,
							text = "11",
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
						name = "zb5",
						varName = "part5Btn",
						posX = 0.6304092,
						posY = 0.1922998,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1434456,
						sizeY = 0.1531827,
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xzt5",
							varName = "is_select5",
							posX = 0.5,
							posY = 0.4669177,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 1.319149,
							sizeY = 1.367383,
							image = "wh#xz",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pjd5",
							varName = "partIcon5",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9042551,
							sizeY = 0.9373192,
							image = "wh#gen",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qhz5",
							varName = "partLvl5",
							posX = 0.1601112,
							posY = 0.8365986,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8872787,
							sizeY = 0.3761843,
							text = "11",
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
						name = "zb6",
						varName = "part6Btn",
						posX = 0.383577,
						posY = 0.1923067,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1434456,
						sizeY = 0.1531827,
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xzt6",
							varName = "is_select6",
							posX = 0.5,
							posY = 0.4669177,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 1.319149,
							sizeY = 1.367383,
							image = "wh#xz",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pjd6",
							varName = "partIcon6",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9042551,
							sizeY = 0.9373192,
							image = "wh#dui",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qhz6",
							varName = "partLvl6",
							posX = 0.1601112,
							posY = 0.8365986,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8872787,
							sizeY = 0.3761843,
							text = "11",
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
						name = "zb7",
						varName = "part7Btn",
						posX = 0.2190465,
						posY = 0.3811911,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1434456,
						sizeY = 0.1531827,
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xzt7",
							varName = "is_select7",
							posX = 0.5,
							posY = 0.4669177,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 1.319149,
							sizeY = 1.367383,
							image = "wh#xz",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pjd7",
							varName = "partIcon7",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9042551,
							sizeY = 0.9373192,
							image = "wh#xun",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qhz7",
							varName = "partLvl7",
							posX = 0.1601112,
							posY = 0.8365986,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8872787,
							sizeY = 0.3761843,
							text = "11",
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
						name = "zb8",
						varName = "part8Btn",
						posX = 0.2190658,
						posY = 0.6392119,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1434456,
						sizeY = 0.1531827,
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "xzt8",
							varName = "is_select8",
							posX = 0.5,
							posY = 0.4669177,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 1.319149,
							sizeY = 1.367383,
							image = "wh#xz",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "pjd8",
							varName = "partIcon8",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9042551,
							sizeY = 0.9373192,
							image = "wh#zhen",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "qhz8",
							varName = "partLvl8",
							posX = 0.1601112,
							posY = 0.8365986,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8872787,
							sizeY = 0.3761843,
							text = "11",
							fontOutlineEnable = true,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Sprite3D",
						name = "mx",
						varName = "soulModule",
						posX = 0.5079631,
						posY = 0.1824878,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4140013,
						sizeY = 0.5186915,
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
				posY = 0.8974048,
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
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#whxx",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh9",
				varName = "wuhunBtn",
				posX = 0.8703203,
				posY = 0.6962649,
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
					name = "dsa",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "武魂",
					color = "FFEBC6B4",
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
				name = "qh10",
				varName = "xingyaoBtn",
				posX = 0.8703203,
				posY = 0.5270833,
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
					name = "dsa2",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "星耀",
					color = "FFEBC6B4",
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
				name = "qh11",
				varName = "shendouBtn",
				posX = 0.8703203,
				posY = 0.3645833,
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
					name = "dsa3",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "天枢",
					color = "FFEBC6B4",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
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
	kuang = {
		kuang = {
			alpha = {{0, {0.5}}, {500, {1}}, {1000, {0.5}}, },
		},
	},
	l = {
		l = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l2 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	l2 = {
		l3 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l4 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	kuang2 = {
		kuang2 = {
			alpha = {{0, {0.5}}, {500, {1}}, {1000, {0.5}}, },
		},
	},
	l3 = {
		l5 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l6 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	l4 = {
		l7 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l8 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_kuang = {
		{0,"kuang", -1, 0},
		{2,"lizi", 1, 0},
		{2,"lizi2", 1, 0},
		{2,"lizi3", 1, 0},
		{2,"lizi4", 1, 0},
		{0,"l", -1, 0},
		{0,"l2", -1, 500},
	},
	c_kuang2 = {
		{2,"lizi5", 1, 0},
		{2,"lizi6", 1, 0},
		{2,"lizi7", 1, 0},
		{2,"lizi8", 1, 0},
		{0,"kuang2", -1, 0},
		{0,"l3", -1, 0},
		{0,"l4", -1, 500},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
