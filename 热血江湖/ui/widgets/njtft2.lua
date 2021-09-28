--version = 1
local l_fileType = "node"

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
			etype = "Grid",
			name = "jd",
			posX = 0.4882933,
			posY = 0.4958353,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9577997,
			sizeY = 0.9577997,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bjt",
				posX = 0.5,
				posY = 0.4691695,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.834375,
				sizeY = 0.6884081,
				image = "tfbj#tfbj",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jt1",
					posX = 0.1793656,
					posY = 0.7361318,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03277154,
					sizeY = 0.1248729,
					image = "njtf#jt",
					scale9 = true,
					scale9Top = 0.1,
					scale9Bottom = 0.8,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt2",
					posX = 0.5,
					posY = 0.3796108,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03277154,
					sizeY = 0.3666018,
					image = "njtf#jt",
					scale9 = true,
					scale9Top = 0.1,
					scale9Bottom = 0.8,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt3",
					posX = 0.5,
					posY = 0.7361318,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03277154,
					sizeY = 0.1248729,
					image = "njtf#jt",
					scale9 = true,
					scale9Top = 0.1,
					scale9Bottom = 0.8,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jt4",
					posX = 0.8318521,
					posY = 0.257983,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03277154,
					sizeY = 0.1248729,
					image = "njtf#jt",
					scale9 = true,
					scale9Top = 0.1,
					scale9Bottom = 0.8,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bj1",
					posX = 0.7894419,
					posY = 1.043805,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.376456,
					sizeY = 0.06657873,
					image = "d#bj",
					scale9 = true,
					scale9Left = 0.6,
					scale9Right = 0.2,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bj2",
					posX = 0.2107007,
					posY = 1.043805,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.376456,
					sizeY = 0.06657873,
					image = "d#bj",
					scale9 = true,
					scale9Left = 0.6,
					scale9Right = 0.2,
					flippedX = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tfd",
				posX = 0.5,
				posY = 0.847221,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.190311,
				sizeY = 0.09577736,
				image = "njtf#top1",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "ftd2",
					posX = -1.145833,
					posY = 0.5022982,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7670504,
					sizeY = 0.7692781,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ztr",
						posX = 0.5282525,
						posY = 0.3128535,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8838345,
						sizeY = 1.847373,
						text = "总投入：",
						color = "FFC13110",
						fontSize = 24,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "trsl",
						varName = "totalpoint",
						posX = 0.9663149,
						posY = 0.3128531,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7151076,
						sizeY = 1.847373,
						text = "5",
						color = "FFC13110",
						fontSize = 24,
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
				name = "bp",
				varName = "item_bg1",
				posX = 0.23,
				posY = 0.7149837,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2054688,
				sizeY = 0.08055556,
				image = "nj#db1",
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
					name = "tb2",
					posX = 0.04278489,
					posY = 0.5080866,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3269961,
					sizeY = 1.706897,
					image = "nj#tfk",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "anan",
					varName = "item_btn1",
					posX = 0.5036054,
					posY = 0.5145044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.000399,
					sizeY = 1.000017,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aan",
						posX = 0.9667174,
						posY = 0.4483514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2546512,
						sizeY = 1.137912,
						image = "nj#jia",
						imageNormal = "nj#jia",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb",
					varName = "item_icon1",
					posX = 0.04278487,
					posY = 0.5253279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3422053,
					sizeY = 1.706897,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jiangu",
					varName = "item_name1",
					posX = 0.5342207,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6376548,
					sizeY = 0.7681323,
					text = "坚固",
					color = "FFFFF150",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sld1",
					posX = 0.04065841,
					posY = -0.1883286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2737642,
					sizeY = 0.5862069,
					image = "njtf#sld1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs",
						varName = "item_value1",
						posX = 0.5,
						posY = 0.647059,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.670963,
						sizeY = 1.229186,
						text = "0/5",
						fontSize = 22,
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
				name = "bp2",
				varName = "item_bg2",
				posX = 0.5,
				posY = 0.7149837,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2054688,
				sizeY = 0.08055556,
				image = "nj#db1",
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
					name = "tb3",
					posX = 0.04278487,
					posY = 0.5080866,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3269961,
					sizeY = 1.706897,
					image = "nj#tfk",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "anan2",
					varName = "item_btn2",
					posX = 0.5036054,
					posY = 0.5145044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.000399,
					sizeY = 1.000017,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aan2",
						posX = 0.9667174,
						posY = 0.4483514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2546512,
						sizeY = 1.137912,
						image = "nj#jia",
						imageNormal = "nj#jia",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb4",
					varName = "item_icon2",
					posX = 0.04278487,
					posY = 0.5253279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3422053,
					sizeY = 1.706897,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jiangu2",
					varName = "item_name2",
					posX = 0.5342207,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6376548,
					sizeY = 0.7681323,
					text = "坚固",
					color = "FFFFF150",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sld2",
					posX = 0.04065841,
					posY = -0.1883286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2737642,
					sizeY = 0.5862069,
					image = "njtf#sld1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs2",
						varName = "item_value2",
						posX = 0.5,
						posY = 0.647059,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.670963,
						sizeY = 1.229186,
						text = "0/5",
						fontSize = 22,
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
				name = "bp3",
				varName = "item_bg3",
				posX = 0.23,
				posY = 0.5507011,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2054688,
				sizeY = 0.08055556,
				image = "nj#db1",
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
					name = "tb5",
					posX = 0.04278487,
					posY = 0.5080866,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3269961,
					sizeY = 1.706897,
					image = "nj#tfk",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "anan3",
					varName = "item_btn3",
					posX = 0.5036054,
					posY = 0.5145044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.000399,
					sizeY = 1.000017,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aan3",
						posX = 0.9667174,
						posY = 0.4483514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2546512,
						sizeY = 1.137912,
						image = "nj#jia",
						imageNormal = "nj#jia",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb6",
					varName = "item_icon3",
					posX = 0.04278487,
					posY = 0.5253279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3422053,
					sizeY = 1.706897,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jiangu3",
					varName = "item_name3",
					posX = 0.5342207,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6376548,
					sizeY = 0.7681323,
					text = "坚固",
					color = "FFFFF150",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sld3",
					posX = 0.04065841,
					posY = -0.1883286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2737642,
					sizeY = 0.5862069,
					image = "njtf#sld1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs3",
						varName = "item_value3",
						posX = 0.5,
						posY = 0.647059,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.670963,
						sizeY = 1.229186,
						text = "0/5",
						fontSize = 22,
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
				name = "bp4",
				varName = "item_bg4",
				posX = 0.4999999,
				posY = 0.5507011,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2054688,
				sizeY = 0.08055556,
				image = "nj#db1",
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
					name = "tb7",
					posX = 0.04278487,
					posY = 0.5080866,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3269961,
					sizeY = 1.706897,
					image = "nj#tfk",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "anan4",
					varName = "item_btn4",
					posX = 0.5036054,
					posY = 0.5145044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.000399,
					sizeY = 1.000017,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aan4",
						posX = 0.9667174,
						posY = 0.4483514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2546512,
						sizeY = 1.137912,
						image = "nj#jia",
						imageNormal = "nj#jia",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb8",
					varName = "item_icon4",
					posX = 0.04278487,
					posY = 0.5253279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3422053,
					sizeY = 1.706897,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jiangu4",
					varName = "item_name4",
					posX = 0.5342207,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6376548,
					sizeY = 0.7681323,
					text = "坚固",
					color = "FFFFF150",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sld4",
					posX = 0.04065841,
					posY = -0.1883286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2737642,
					sizeY = 0.5862069,
					image = "njtf#sld1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs4",
						varName = "item_value4",
						posX = 0.5,
						posY = 0.647059,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.670963,
						sizeY = 1.229186,
						text = "0/5",
						fontSize = 22,
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
				name = "bp5",
				varName = "item_bg5",
				posX = 0.23,
				posY = 0.3864185,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2054688,
				sizeY = 0.08055556,
				image = "nj#db1",
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
					name = "tb9",
					posX = 0.04278487,
					posY = 0.5080866,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3269961,
					sizeY = 1.706897,
					image = "nj#tfk",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "anan5",
					varName = "item_btn5",
					posX = 0.5036054,
					posY = 0.5145044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.000399,
					sizeY = 1.000017,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aan5",
						posX = 0.9667174,
						posY = 0.4483514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2546512,
						sizeY = 1.137912,
						image = "nj#jia",
						imageNormal = "nj#jia",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb10",
					varName = "item_icon5",
					posX = 0.04278487,
					posY = 0.5253279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3422053,
					sizeY = 1.706897,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jiangu5",
					varName = "item_name5",
					posX = 0.5342207,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6376548,
					sizeY = 0.7681323,
					text = "坚固",
					color = "FFFFF150",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sld5",
					posX = 0.04065841,
					posY = -0.1883286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2737642,
					sizeY = 0.5862069,
					image = "njtf#sld1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs5",
						varName = "item_value5",
						posX = 0.5,
						posY = 0.647059,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.670963,
						sizeY = 1.229186,
						text = "0/5",
						fontSize = 22,
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
				name = "bp6",
				varName = "item_bg6",
				posX = 0.77,
				posY = 0.3864185,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2054688,
				sizeY = 0.08055556,
				image = "nj#db1",
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
					name = "tb11",
					posX = 0.04278487,
					posY = 0.5080866,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3269961,
					sizeY = 1.706897,
					image = "nj#tfk",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "anan6",
					varName = "item_btn6",
					posX = 0.5036054,
					posY = 0.5145044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.000399,
					sizeY = 1.000017,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aan6",
						posX = 0.9667174,
						posY = 0.4483514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2546512,
						sizeY = 1.137912,
						image = "nj#jia",
						imageNormal = "nj#jia",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb12",
					varName = "item_icon6",
					posX = 0.04278487,
					posY = 0.5253279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3422053,
					sizeY = 1.706897,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jiangu6",
					varName = "item_name6",
					posX = 0.5342207,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6376548,
					sizeY = 0.7681323,
					text = "坚固",
					color = "FFFFF150",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sld6",
					posX = 0.04065841,
					posY = -0.1883286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2737642,
					sizeY = 0.5862069,
					image = "njtf#sld1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs6",
						varName = "item_value6",
						posX = 0.5,
						posY = 0.647059,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.670963,
						sizeY = 1.229186,
						text = "0/5",
						fontSize = 22,
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
				name = "bp7",
				varName = "item_bg7",
				posX = 0.4999999,
				posY = 0.2221359,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2054688,
				sizeY = 0.08055556,
				image = "nj#db1",
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
					name = "tb13",
					posX = 0.04278487,
					posY = 0.5080866,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3269961,
					sizeY = 1.706897,
					image = "nj#tfk",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "anan7",
					varName = "item_btn7",
					posX = 0.5036054,
					posY = 0.5145044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.000399,
					sizeY = 1.000017,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aan7",
						posX = 0.9667174,
						posY = 0.4483514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2546512,
						sizeY = 1.137912,
						image = "nj#jia",
						imageNormal = "nj#jia",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb14",
					varName = "item_icon7",
					posX = 0.04278487,
					posY = 0.5253279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3422053,
					sizeY = 1.706897,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jiangu7",
					varName = "item_name7",
					posX = 0.5342207,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6376548,
					sizeY = 0.7681323,
					text = "坚固",
					color = "FFFFF150",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sld7",
					posX = 0.04065841,
					posY = -0.1883286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2737642,
					sizeY = 0.5862069,
					image = "njtf#sld1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs7",
						varName = "item_value7",
						posX = 0.5,
						posY = 0.647059,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.670963,
						sizeY = 1.229186,
						text = "0/5",
						fontSize = 22,
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
				name = "bp8",
				varName = "item_bg8",
				posX = 0.77,
				posY = 0.2221359,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2054688,
				sizeY = 0.08055556,
				image = "nj#db1",
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
					name = "tb15",
					posX = 0.04278487,
					posY = 0.5080866,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3269961,
					sizeY = 1.706897,
					image = "nj#tfk",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "anan8",
					varName = "item_btn8",
					posX = 0.5036054,
					posY = 0.5145044,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.000399,
					sizeY = 1.000017,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "aan8",
						posX = 0.9667174,
						posY = 0.4483514,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2546512,
						sizeY = 1.137912,
						image = "nj#jia",
						imageNormal = "nj#jia",
						disablePressScale = true,
						disableClick = true,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tb16",
					varName = "item_icon8",
					posX = 0.04278487,
					posY = 0.5253279,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3422053,
					sizeY = 1.706897,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "jiangu8",
					varName = "item_name8",
					posX = 0.5342207,
					posY = 0.499999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6376548,
					sizeY = 0.7681323,
					text = "坚固",
					color = "FFFFF150",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sld8",
					posX = 0.04065841,
					posY = -0.1883286,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2737642,
					sizeY = 0.5862069,
					image = "njtf#sld1",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "cs8",
						varName = "item_value8",
						posX = 0.5,
						posY = 0.647059,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.670963,
						sizeY = 1.229186,
						text = "0/5",
						fontSize = 22,
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
				etype = "Label",
				name = "sm",
				varName = "nextAddPointAttr",
				posX = 0.8227304,
				posY = 0.8336523,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2188007,
				sizeY = 0.08475352,
				text = "（下级升级增加2点）",
				color = "FF634624",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "resetTalent",
				posX = 0.5,
				posY = 0.07093962,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1419269,
				sizeY = 0.09570546,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "cz",
					posX = 0.506135,
					posY = 0.530303,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7533577,
					sizeY = 0.6863645,
					text = "重置天赋",
					fontSize = 22,
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
				etype = "Label",
				name = "tfdsl",
				varName = "residuePoint",
				posX = 0.595277,
				posY = 0.8472211,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1159235,
				sizeY = 0.08756167,
				text = "55",
				color = "FFFFED28",
				fontSize = 26,
				fontOutlineEnable = true,
				fontOutlineColor = "FF3B0000",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sytfd",
				posX = 0.4575158,
				posY = 0.847221,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1490195,
				sizeY = 0.08756167,
				text = "剩余点数：",
				color = "FFFEF493",
				fontSize = 26,
				fontOutlineEnable = true,
				fontOutlineColor = "FF5C0F0A",
				fontOutlineSize = 2,
				hTextAlign = 2,
				vTextAlign = 1,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
