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
				name = "czjm",
				posX = 0.5,
				posY = 0.4763887,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7877671,
				sizeY = 0.8020901,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.45,
				scale9Top = 0.3,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "kk1",
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
						name = "fa2",
						posX = 1.018942,
						posY = 0.6154988,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04819277,
						sizeY = 0.7290016,
						image = "sc#scz1",
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "fa1",
						posX = -0.01896021,
						posY = 0.6154988,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04819277,
						sizeY = 0.7290016,
						image = "sc#scz1",
					},
				},
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
						name = "db3",
						posX = 0.5,
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
						name = "sd2",
						posX = 0.09648415,
						posY = 0.9701336,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1299484,
						sizeY = 0.06022187,
						image = "sc#scz2",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sd1",
						posX = 0.9227158,
						posY = 0.9493544,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1299484,
						sizeY = 0.06022187,
						image = "sc#scz2",
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sd3",
						posX = 0.7200308,
						posY = 0.9554855,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4388984,
						sizeY = 0.1141046,
						image = "sc#scz3",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sd4",
						posX = 0.2814076,
						posY = 0.9554855,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4388984,
						sizeY = 0.1141046,
						image = "sc#scz3",
						flippedX = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.5,
					posY = 0.4170688,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8766698,
					sizeY = 0.6914988,
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
						name = "lbt",
						varName = "desc_scroll",
						posX = 0.3313883,
						posY = 0.4213916,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6234217,
						sizeY = 0.8077027,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "top2",
						varName = "wholefuncTitel",
						posX = 0.3313883,
						posY = 0.9039807,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3396279,
						sizeY = 0.139535,
						image = "chu1#zld",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz3",
							varName = "funcTitel",
							posX = 0.3007859,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4555174,
							sizeY = 0.9519894,
							text = "VIP 11",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFD76D56",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
							colorBR = "FFFCFA4B",
							colorBL = "FFFCFA4B",
							useQuadColor = true,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wz4",
							posX = 0.6782765,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4555174,
							sizeY = 0.9519894,
							text = "尊贵特权",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFD76D56",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
							colorBR = "FFFCFA4B",
							colorBL = "FFFCFA4B",
							useQuadColor = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "fgx",
						posX = 0.7160261,
						posY = 0.5000001,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1303809,
						sizeY = 1.007405,
						image = "fgx#fgx",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dg",
					posX = 0.1298987,
					posY = 0.8725474,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1705771,
					sizeY = 0.2909066,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "vip",
						varName = "vipLvl",
						posX = 0.7728087,
						posY = 0.3899481,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 1.174418,
						sizeY = 0.3452381,
						image = "vip#v15",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jdd",
					posX = 0.5,
					posY = 0.8101787,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.421484,
					sizeY = 0.05541079,
					image = "chu1#jdd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "LoadingBar",
						name = "jd",
						varName = "percent",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9647059,
						sizeY = 0.6249999,
						image = "tong#jdt",
						scale9Left = 0.4,
						scale9Right = 0.4,
						percent = 40,
						imageHead = "ty#guang",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "tsz2",
						varName = "percentText",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8301919,
						sizeY = 1.457464,
						text = "3580/15000",
						fontOutlineEnable = true,
						fontOutlineColor = "FF5B7838",
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
					name = "db2",
					posX = 0.7897765,
					posY = 0.413795,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3054187,
					sizeY = 0.7413793,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj1",
						varName = "reward1",
						posX = 0.305156,
						posY = 0.7054502,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3064516,
						sizeY = 0.2232558,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "an1",
							varName = "showBtn1",
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
							name = "djt1",
							varName = "ricon1",
							posX = 0.4894737,
							posY = 0.5416668,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl1",
							varName = "num1",
							posX = 0.5706668,
							posY = 0.1861561,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6572995,
							sizeY = 0.4407699,
							text = "x10",
							fontSize = 18,
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo",
							varName = "suo1",
							posX = 0.1741853,
							posY = 0.2088136,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.2842106,
							sizeY = 0.28125,
							image = "tb#suo",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj2",
						varName = "reward2",
						posX = 0.6915617,
						posY = 0.7054502,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3064516,
						sizeY = 0.2232558,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "an2",
							varName = "showBtn2",
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
							name = "djt2",
							varName = "ricon2",
							posX = 0.5,
							posY = 0.5416668,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl2",
							varName = "num2",
							posX = 0.5706668,
							posY = 0.1861561,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6572995,
							sizeY = 0.4407699,
							text = "x10",
							fontSize = 18,
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo2",
							varName = "suo2",
							posX = 0.1741853,
							posY = 0.2088136,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.2842106,
							sizeY = 0.28125,
							image = "tb#suo",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj3",
						varName = "reward3",
						posX = 0.305156,
						posY = 0.4593074,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3064516,
						sizeY = 0.2232558,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "an3",
							varName = "showBtn3",
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
							name = "djt3",
							varName = "ricon3",
							posX = 0.5,
							posY = 0.5416668,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl3",
							varName = "num3",
							posX = 0.5706668,
							posY = 0.1861561,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6572995,
							sizeY = 0.4407699,
							text = "x10",
							fontSize = 18,
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo3",
							varName = "suo3",
							posX = 0.1741853,
							posY = 0.2088136,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.2842106,
							sizeY = 0.28125,
							image = "tb#suo",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dj4",
						varName = "reward4",
						posX = 0.6915617,
						posY = 0.4593074,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3064516,
						sizeY = 0.2232558,
						image = "djk#ktong",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "an4",
							varName = "showBtn4",
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
							name = "djt4",
							varName = "ricon4",
							posX = 0.5,
							posY = 0.5416668,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8,
							sizeY = 0.8,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "sl4",
							varName = "num4",
							posX = 0.5706668,
							posY = 0.1861561,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6572995,
							sizeY = 0.4407699,
							text = "x10",
							fontSize = 18,
							fontOutlineEnable = true,
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "suo4",
							varName = "suo4",
							posX = 0.1741853,
							posY = 0.2088136,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.2842106,
							sizeY = 0.28125,
							image = "tb#suo",
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "lq",
						varName = "takeReward",
						posX = 0.5,
						posY = 0.125297,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5649965,
						sizeY = 0.1541515,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "lqz",
							posX = 0.5,
							posY = 0.5454545,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7445254,
							sizeY = 1.107772,
							text = "购 买",
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
						name = "top1",
						varName = "wholegiftTitle",
						posX = 0.5,
						posY = 0.9039807,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.008593,
						sizeY = 0.1186047,
						image = "sc#mzd",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wz1",
							varName = "giftTitle",
							posX = 0.3007859,
							posY = 0.3080664,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4555174,
							sizeY = 0.9519894,
							text = "VIP 11",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFD76D56",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
							colorBR = "FFFCFA4B",
							colorBL = "FFFCFA4B",
							useQuadColor = true,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "wz2",
							posX = 0.6782765,
							posY = 0.3080664,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.4555174,
							sizeY = 0.9519894,
							text = "稀有礼包",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFD76D56",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
							colorBR = "FFFCFA4B",
							colorBL = "FFFCFA4B",
							useQuadColor = true,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "yuan",
						varName = "diamondIcon",
						posX = 0.4002213,
						posY = 0.2586332,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1612903,
						sizeY = 0.1162791,
						image = "tb#yuanbao",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tsz3",
							varName = "diamondNum",
							posX = 2.203082,
							posY = 0.446034,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.359436,
							sizeY = 0.9266882,
							text = "x5000",
							color = "FF966856",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "yuan2",
						varName = "diamondIcon2",
						posX = 0.4002213,
						posY = 0.3170651,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1612903,
						sizeY = 0.1162791,
						image = "tb#yuanbao",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tsz4",
							varName = "diamondNum2",
							posX = 2.203082,
							posY = 0.446034,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.359436,
							sizeY = 0.9266882,
							text = "x5000",
							color = "FF966856",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xian",
							posX = 1.504627,
							posY = 0.4800237,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 3.643903,
							sizeY = 0.1606912,
							image = "sc#hx",
							rotation = 6,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "yuan3",
						varName = "diamondIcon3",
						posX = 0.4002213,
						posY = 0.2399894,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1612903,
						sizeY = 0.1162791,
						image = "tb#yuanbao",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tsz5",
							varName = "diamondNum3",
							posX = 2.203082,
							posY = 0.446034,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 2.359436,
							sizeY = 0.9266882,
							text = "x5000",
							color = "FF966856",
							fontSize = 22,
							fontOutlineColor = "FF27221D",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "tips",
							varName = "tipsBt",
							posX = 3.144837,
							posY = 0.5681994,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6844901,
							sizeY = 0.6427649,
							image = "tong#tsf",
							imageNormal = "tong#tsf",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zk",
							varName = "discountImage",
							posX = -0.7764859,
							posY = 0.4275103,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.590433,
							sizeY = 0.9038882,
							image = "sc#5z",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dg3",
					posX = 0.5,
					posY = 0.8789901,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4427273,
					sizeY = 0.05873016,
					alpha = 0.5,
				},
				children = {
				{
					prop = {
						etype = "RichText",
						name = "cwz2",
						varName = "title",
						posX = 0.49776,
						posY = 0.3626942,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9622795,
						sizeY = 1.328662,
						text = "再储值15000元宝，您将成为",
						color = "FFFF761B",
						fontSize = 22,
						fontOutlineColor = "FFA0423B",
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
					name = "lq2",
					varName = "channel_pay_btn",
					posX = 0.8293219,
					posY = 0.835188,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1725605,
					sizeY = 0.1142847,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "czz",
						posX = 0.5,
						posY = 0.5454545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8430817,
						sizeY = 0.8169187,
						text = "储 值",
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
					posY = 0.9997103,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.261816,
					sizeY = 0.09004253,
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
						sizeX = 0.5151514,
						sizeY = 0.4807692,
						image = "biaoti#tq",
					},
				},
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "you",
				varName = "right",
				posX = 0.8689232,
				posY = 0.4388884,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04991808,
				sizeY = 0.3577449,
				propagateToChildren = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "ff",
					posX = 0.4530482,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6729776,
					sizeY = 0.2096466,
					image = "chu1#jiantou",
					imageNormal = "chu1#jiantou",
					disableClick = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "you2",
				varName = "left",
				posX = 0.1330391,
				posY = 0.4388884,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.04991808,
				sizeY = 0.3577449,
				propagateToChildren = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "fff",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6729776,
					sizeY = 0.2096466,
					image = "chu1#jiantou",
					imageNormal = "chu1#jiantou",
					disableClick = true,
					flippedX = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "close_btn",
				posX = 0.8664612,
				posY = 0.8247179,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
