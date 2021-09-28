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
				name = "kk1",
				posX = 0.5,
				posY = 0.4577084,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9078125,
				sizeY = 0.8763889,
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
					posX = 0.491394,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9363167,
					sizeY = 0.9746434,
					image = "b#db2",
					scale9 = true,
					scale9Left = 0.47,
					scale9Right = 0.47,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "title",
					posX = 0.5,
					posY = 0.9873216,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.07401,
					sizeY = 0.08082409,
					image = "b#top",
					scale9 = true,
					scale9Left = 0.49,
					scale9Right = 0.49,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "z1",
				posX = 0.2785207,
				posY = 0.4534763,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3984375,
				sizeY = 0.8222222,
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
					posX = 0.5176472,
					posY = 0.454756,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.011765,
					sizeY = 0.766892,
					image = "xunyangbj#xunyangbj",
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "bgt",
						posX = 0.7244374,
						posY = 1.09638,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.5406976,
						sizeY = 0.1101322,
						image = "chu1#zld",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "zl",
							varName = "pet_power",
							posX = 0.5070133,
							posY = 0.5000003,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7138616,
							sizeY = 1.061954,
							text = "455546",
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
							posX = 0.2564197,
							posY = 0.5043473,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.125448,
							sizeY = 0.6400001,
							image = "tong#zl",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "jt",
							varName = "addIcon",
							posX = 0.7612178,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1075269,
							sizeY = 0.6000001,
							image = "chu1#ss",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "pz",
							varName = "powerValue",
							posX = 1.144291,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6576322,
							sizeY = 1.353146,
							text = "6666",
							color = "FF029133",
							fontSize = 22,
							vTextAlign = 1,
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
					varName = "equip1",
					posX = 0.1099252,
					posY = 0.7420236,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1663285,
					sizeY = 0.1385135,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd1",
						varName = "grade_icon1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.011957,
						sizeY = 1.037429,
						image = "xunyang#676",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt1",
						varName = "equip_icon1",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jd",
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
							etype = "FrameAni",
							name = "sd3",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an11",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xl_003.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					{
						prop = {
							etype = "FrameAni",
							name = "sd4",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an12",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xll_001.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz1",
						varName = "qh_level1",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ts1",
						varName = "tips1",
						posX = 0.8517831,
						posY = 0.885722,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.2878123,
						sizeY = 0.308764,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzt1",
						varName = "is_select1",
						posX = 0.5,
						posY = 0.5432262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.10861,
						sizeY = 1.146838,
						image = "djk#zbxz",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzb1",
						varName = "repair1",
						posX = 0.7232507,
						posY = 0.3181197,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3411109,
						sizeY = 0.3528731,
						image = "bg2#chuizi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zb2",
					varName = "equip2",
					posX = 0.9261733,
					posY = 0.7420236,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1663285,
					sizeY = 0.1385135,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd2",
						varName = "grade_icon2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.011957,
						sizeY = 1.037429,
						image = "xunyang#454",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt2",
						varName = "equip_icon2",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jd2",
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
							etype = "FrameAni",
							name = "sd9",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an21",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xl_003.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					{
						prop = {
							etype = "FrameAni",
							name = "sd10",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an22",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xll_001.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz2",
						varName = "qh_level2",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ts2",
						varName = "tips2",
						posX = 0.8517831,
						posY = 0.885722,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2878123,
						sizeY = 0.308764,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzt2",
						varName = "is_select2",
						posX = 0.5,
						posY = 0.5432262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.10861,
						sizeY = 1.146838,
						image = "djk#zbxz",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzb2",
						varName = "repair2",
						posX = 0.7232507,
						posY = 0.3181197,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3411109,
						sizeY = 0.3528731,
						image = "bg2#chuizi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zb3",
					varName = "equip3",
					posX = 0.1099252,
					posY = 0.581405,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1663285,
					sizeY = 0.1385135,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd3",
						varName = "grade_icon3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.011957,
						sizeY = 1.037429,
						image = "xunyang#565",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt3",
						varName = "equip_icon3",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jd3",
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
							etype = "FrameAni",
							name = "sd5",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an31",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xl_003.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					{
						prop = {
							etype = "FrameAni",
							name = "sd6",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an32",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xll_001.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz3",
						varName = "qh_level3",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ts3",
						varName = "tips3",
						posX = 0.8517831,
						posY = 0.885722,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2878123,
						sizeY = 0.308764,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzt3",
						varName = "is_select3",
						posX = 0.5,
						posY = 0.5432262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.10861,
						sizeY = 1.146838,
						image = "djk#zbxz",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzb3",
						varName = "repair3",
						posX = 0.7232507,
						posY = 0.3181197,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3411109,
						sizeY = 0.3528731,
						image = "bg2#chuizi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zb4",
					varName = "equip4",
					posX = 0.9261734,
					posY = 0.581405,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1663285,
					sizeY = 0.1385135,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd4",
						varName = "grade_icon4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.011957,
						sizeY = 1.037429,
						image = "xunyang#454",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt4",
						varName = "equip_icon4",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jd4",
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
							etype = "FrameAni",
							name = "sd11",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an41",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xl_003.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					{
						prop = {
							etype = "FrameAni",
							name = "sd12",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an42",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xll_001.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz4",
						varName = "qh_level4",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ts4",
						varName = "tips4",
						posX = 0.8517831,
						posY = 0.885722,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2878123,
						sizeY = 0.308764,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzt4",
						varName = "is_select4",
						posX = 0.5,
						posY = 0.5432262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.10861,
						sizeY = 1.146838,
						image = "djk#zbxz",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzb4",
						varName = "repair4",
						posX = 0.7232507,
						posY = 0.3181197,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3411109,
						sizeY = 0.3528731,
						image = "bg2#chuizi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zb5",
					varName = "equip5",
					posX = 0.1099252,
					posY = 0.4207863,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1663285,
					sizeY = 0.1385135,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd5",
						varName = "grade_icon5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.011957,
						sizeY = 1.037429,
						image = "xunyang#32",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt5",
						varName = "equip_icon5",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jd5",
						posX = 0.5,
						posY = 0.4878049,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
					},
					children = {
					{
						prop = {
							etype = "FrameAni",
							name = "sd7",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an51",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xl_003.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					{
						prop = {
							etype = "FrameAni",
							name = "sd8",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an52",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xll_001.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz5",
						varName = "qh_level5",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ts5",
						varName = "tips5",
						posX = 0.8517831,
						posY = 0.885722,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2878123,
						sizeY = 0.308764,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzt5",
						varName = "is_select5",
						posX = 0.5,
						posY = 0.5432262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.10861,
						sizeY = 1.146838,
						image = "djk#zbxz",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzb5",
						varName = "repair5",
						posX = 0.7232507,
						posY = 0.3181197,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3411109,
						sizeY = 0.3528731,
						image = "bg2#chuizi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "zb6",
					varName = "equip6",
					posX = 0.9261734,
					posY = 0.4207863,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1663285,
					sizeY = 0.1385135,
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "pjd6",
						varName = "grade_icon6",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.011957,
						sizeY = 1.037429,
						image = "xunyang#32",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zbt6",
						varName = "equip_icon6",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jd6",
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
							etype = "FrameAni",
							name = "sd13",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an61",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xl_003.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					{
						prop = {
							etype = "FrameAni",
							name = "sd14",
							sizeXAB = 83.48949,
							sizeYAB = 77.75759,
							posXAB = 43.1811,
							posYAB = 43.97931,
							varName = "an62",
							posX = 0.5090457,
							posY = 0.5363331,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							lockHV = true,
							sizeX = 0.9842263,
							sizeY = 0.9482635,
							frameEnd = 16,
							frameName = "uieffect/xll_001.png",
							delay = 0.05,
							frameWidth = 64,
							frameHeight = 64,
							column = 4,
							blendFunc = 1,
							repeatLastFrame = 35,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "qhz6",
						varName = "qh_level6",
						posX = 0.4342432,
						posY = 0.2310104,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7248785,
						sizeY = 0.3761843,
						text = "+11",
						fontOutlineEnable = true,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ts6",
						varName = "tips6",
						posX = 0.8517831,
						posY = 0.885722,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2878123,
						sizeY = 0.308764,
						image = "zdte#hd",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzt6",
						varName = "is_select6",
						posX = 0.5,
						posY = 0.5432262,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.10861,
						sizeY = 1.146838,
						image = "djk#zbxz",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "xzb6",
						varName = "repair6",
						posX = 0.7232507,
						posY = 0.3181197,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.3411109,
						sizeY = 0.3528731,
						image = "bg2#chuizi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "xz",
					varName = "revolve",
					posX = 0.5176472,
					posY = 0.48491,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6757718,
					sizeY = 0.6560169,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lie",
					varName = "petScroll",
					posX = 0.5156865,
					posY = 0.07839273,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9803922,
					sizeY = 0.1435811,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tj1",
					posX = 0.2368597,
					posY = 0.9112174,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.404747,
					sizeY = 0.08108109,
					image = "b#srk",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "dj2",
						varName = "choseGroupBtn",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						disablePressScale = true,
						propagateToChildren = true,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "jih",
							varName = "filterBtn",
							posX = 0.1143712,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.2083122,
							sizeY = 0.9166667,
							image = "pmh#jiantou",
							imageNormal = "pmh#jiantou",
							disableClick = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wz1",
						varName = "groupLabel",
						posX = 0.6058287,
						posY = 0.5221087,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7690037,
						sizeY = 1,
						text = "xx之队",
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
					name = "fl4",
					varName = "choseGroupUI",
					posX = 0.2368597,
					posY = 0.871529,
					anchorX = 0.5,
					anchorY = 1,
					visible = false,
					sizeX = 0.404747,
					sizeY = 0.3487115,
					image = "b#bp",
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
						name = "fl5",
						posX = 0.5,
						posY = 1,
						anchorX = 0.5,
						anchorY = 1,
						visible = false,
						sizeX = 1,
						sizeY = 1,
						image = "b#bp",
						scale9 = true,
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb2",
						varName = "choseGroupScroll",
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
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh8",
				varName = "upLvl_btn",
				posX = 0.9319386,
				posY = 0.5672125,
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
					posX = 0.4995588,
					posY = 0.5130718,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "装备升级",
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
					name = "hd2",
					varName = "upLvlPoint",
					posX = 0.7694741,
					posY = 0.7978233,
					anchorX = 0.5,
					anchorY = 0.5,
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
				name = "qh9",
				varName = "bag_btn",
				posX = 0.9319386,
				posY = 0.7267957,
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
					posY = 0.5130718,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "宠物装备",
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
					name = "hd",
					varName = "equipPoint",
					posX = 0.7694741,
					posY = 0.7978233,
					anchorX = 0.5,
					anchorY = 0.5,
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
				name = "qh11",
				varName = "skill_btn",
				posX = 0.9319386,
				posY = 0.4076294,
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
					name = "dsa4",
					posX = 0.4995587,
					posY = 0.5138658,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "试炼技能",
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
					varName = "skillPoint",
					posX = 0.7694741,
					posY = 0.7978233,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2727273,
					sizeY = 0.1830065,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx2",
				varName = "hero_module",
				posX = 0.2847824,
				posY = 0.2373979,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2465252,
				sizeY = 0.4559692,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.9274268,
				posY = 0.8660722,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sjtop",
				varName = "sjtop",
				posX = 0.04916242,
				posY = 0.6358366,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08359375,
				sizeY = 0.4986111,
				image = "tong#denglong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tsa",
					posX = 0.471938,
					posY = 0.6473824,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5140187,
					sizeY = 0.2534819,
					image = "xunyang#xunyang",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "fl2",
				varName = "levelRoot",
				posX = 0.8258531,
				posY = 0.7803123,
				anchorX = 0.5,
				anchorY = 1,
				visible = false,
				sizeX = 0.1298236,
				sizeY = 0.420361,
				image = "b#bp",
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
					name = "fl3",
					posX = 0.5,
					posY = 1,
					anchorX = 0.5,
					anchorY = 1,
					visible = false,
					sizeX = 1,
					sizeY = 1,
					image = "b#bp",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "filterScroll",
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
				etype = "Button",
				name = "ss",
				varName = "help_btn",
				posX = 0.9360031,
				posY = 0.1090037,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04765625,
				sizeY = 0.09166667,
				image = "tong#bz",
				imageNormal = "tong#bz",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "jie",
				varName = "newRoot",
				posX = 0.6996472,
				posY = 0.4570198,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4227062,
				sizeY = 0.8054716,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh12",
				varName = "guard_btn",
				posX = 0.9319355,
				posY = 0.2495425,
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
					name = "dsa5",
					posX = 0.4995587,
					posY = 0.5138658,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "守护灵兽",
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
					varName = "guardPoint",
					posX = 0.7694741,
					posY = 0.7978233,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2727273,
					sizeY = 0.1830065,
					image = "zdte#hd",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
