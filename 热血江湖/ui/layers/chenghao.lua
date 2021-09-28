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
			name = "jdk",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "padtop",
				varName = "padtop",
				posX = 0.5,
				posY = 0.9406416,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 0.1152778,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				alphaCascade = true,
				layoutType = 8,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "uu2",
					posX = 0.1849927,
					posY = 0.5602064,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2257813,
					sizeY = 0.7710842,
					image = "ty#pad2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "uu1",
					posX = 0.169735,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.07265625,
					sizeY = 0.4337349,
					image = "bg2#ch",
				},
			},
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
				name = "z2",
				posX = 0.7137104,
				posY = 0.4590964,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4274222,
				sizeY = 0.8333525,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.2921059,
					posY = 0.429265,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.284949,
					sizeY = 0.818643,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Scroll",
						name = "bglb",
						varName = "scroll",
						posX = 0.5,
						posY = 0.4971594,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9819775,
						sizeY = 0.9704325,
					},
				},
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
					name = "dw",
					posX = 0.3346407,
					posY = 0.4975576,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6281067,
					sizeY = 0.9612593,
					image = "d2#dw2",
					scale9 = true,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mzd2",
					posX = 0.4983631,
					posY = 0.02727721,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.8817052,
					sizeY = 0.01303302,
					image = "d#tyd",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "sx1",
						varName = "timeDesc",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9140915,
						sizeY = 1.019367,
						text = "时效：永久",
						color = "FF8E2B29",
						fontSize = 26,
						fontOutlineEnable = true,
						fontOutlineColor = "FFFFF2C8",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "chwz",
						varName = "dressTitleLab",
						posX = 0.4980419,
						posY = 0.8963074,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.6,
						sizeY = 0.1545428,
						text = "称号名字",
						color = "FFFFF554",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF102E21",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "ew1",
					varName = "root1",
					posX = 0.3294104,
					posY = 0.7636629,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6992629,
					sizeY = 0.1948989,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn1",
						varName = "btn_2",
						posX = 0.5,
						posY = 0.5000002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8183761,
						sizeY = 0.6337509,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "mr2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#scd1",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js1",
						varName = "lock_2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#chd3",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo",
							varName = "suo_2",
							posX = 0.5,
							posY = 0.525641,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1392857,
							sizeY = 0.4875002,
							image = "bg2#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tis13",
							varName = "label_2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.5632899,
							sizeY = 0.816806,
							text = "额外称号栏1",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js2",
						varName = "show_2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1093589,
						sizeY = 0.3380131,
						image = "bg2#suod",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tis2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 4.04413,
							sizeY = 1.675499,
							text = "空",
							color = "FFF1E9D7",
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
						name = "zlt2",
						varName = "bg_2",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.270729,
						sizeY = 0.9819116,
						image = "ch/zldw1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "ch2",
							varName = "icon_2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.25,
							sizeY = 0.5000001,
							image = "ch/tianxiawudi",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mr",
					posX = 0.3294104,
					posY = 0.9013369,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5490196,
					sizeY = 0.1351351,
					image = "b#scd1",
					scale9 = true,
					scale9Left = 0.48,
					scale9Right = 0.48,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dse",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6474085,
						sizeY = 0.7321668,
						text = "默认称号栏",
						color = "FF634624",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zlt",
					varName = "bg_1",
					posX = 0.3294104,
					posY = 0.9013368,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.8885737,
					sizeY = 0.1913735,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "ch",
						varName = "icon_1",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.25,
						sizeY = 0.5000001,
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "ew2",
					posX = 0.3294104,
					posY = 0.6266873,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6992629,
					sizeY = 0.1948989,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn2",
						varName = "btn_3",
						posX = 0.5,
						posY = 0.5000002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8183761,
						sizeY = 0.6337509,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "mr3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#scd1",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js3",
						varName = "lock_3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#chd3",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo2",
							varName = "suo_3",
							posX = 0.5,
							posY = 0.525641,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1392857,
							sizeY = 0.4875002,
							image = "bg2#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tis14",
							varName = "label_3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.5632899,
							sizeY = 0.816806,
							text = "额外称号栏1",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js8",
						varName = "show_3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1093589,
						sizeY = 0.3380131,
						image = "bg2#suod",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tis3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 4.04413,
							sizeY = 1.675499,
							text = "空",
							color = "FFF1E9D7",
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
						name = "zlt3",
						varName = "bg_3",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.270729,
						sizeY = 0.9819116,
						image = "ch/zldw1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "ch3",
							varName = "icon_3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.25,
							sizeY = 0.5000001,
							image = "ch/tianxiawudi",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "ew3",
					posX = 0.3294104,
					posY = 0.4897119,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6992629,
					sizeY = 0.1948989,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn3",
						varName = "btn_4",
						posX = 0.5,
						posY = 0.5000002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8183761,
						sizeY = 0.6337509,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "mr4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#scd1",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js4",
						varName = "lock_4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#chd3",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo3",
							varName = "suo_4",
							posX = 0.5,
							posY = 0.525641,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1392857,
							sizeY = 0.4875002,
							image = "bg2#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tis15",
							varName = "label_4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.5632899,
							sizeY = 0.816806,
							text = "额外称号栏1",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js9",
						varName = "show_4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1093589,
						sizeY = 0.3380131,
						image = "bg2#suod",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tis4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 4.04413,
							sizeY = 1.675499,
							text = "空",
							color = "FFF1E9D7",
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
						name = "zlt4",
						varName = "bg_4",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.270729,
						sizeY = 0.9819116,
						image = "ch/zldw1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "ch4",
							varName = "icon_4",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.25,
							sizeY = 0.5000001,
							image = "ch/tianxiawudi",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "ew4",
					posX = 0.3294104,
					posY = 0.3527364,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6992629,
					sizeY = 0.1948989,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn4",
						varName = "btn_5",
						posX = 0.5,
						posY = 0.5000002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8183761,
						sizeY = 0.6337509,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "mr5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#scd1",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js5",
						varName = "lock_5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#chd3",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo4",
							varName = "suo_5",
							posX = 0.5,
							posY = 0.525641,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1392857,
							sizeY = 0.4875002,
							image = "bg2#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tis16",
							varName = "label_5",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.5632899,
							sizeY = 0.816806,
							text = "额外称号栏1",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js10",
						varName = "show_5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1093589,
						sizeY = 0.3380131,
						image = "bg2#suod",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tis5",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 4.04413,
							sizeY = 1.675499,
							text = "空",
							color = "FFF1E9D7",
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
						name = "zlt5",
						varName = "bg_5",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.270729,
						sizeY = 0.9819116,
						image = "ch/zldw1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "ch5",
							varName = "icon_5",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.25,
							sizeY = 0.5000001,
							image = "ch/tianxiawudi",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "ew5",
					posX = 0.3294104,
					posY = 0.2157608,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6992629,
					sizeY = 0.1948989,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn5",
						varName = "btn_6",
						posX = 0.5,
						posY = 0.5000002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8183761,
						sizeY = 0.6337509,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "mr6",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#scd1",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js6",
						varName = "lock_6",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#chd3",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo5",
							varName = "suo_6",
							posX = 0.5,
							posY = 0.525641,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1392857,
							sizeY = 0.4875002,
							image = "bg2#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tis17",
							varName = "label_6",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.5632899,
							sizeY = 0.816806,
							text = "额外称号栏1",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js11",
						varName = "show_6",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1093589,
						sizeY = 0.3380131,
						image = "bg2#suod",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tis6",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 4.04413,
							sizeY = 1.675499,
							text = "空",
							color = "FFF1E9D7",
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
						name = "zlt6",
						varName = "bg_6",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.270729,
						sizeY = 0.9819116,
						image = "ch/zldw1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "ch6",
							varName = "icon_6",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.25,
							sizeY = 0.5000001,
							image = "ch/tianxiawudi",
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "ew6",
					posX = 0.3294104,
					posY = 0.07878533,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6992629,
					sizeY = 0.1948989,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "btn6",
						varName = "btn_7",
						posX = 0.5,
						posY = 0.5000002,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8183761,
						sizeY = 0.6337509,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "mr7",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#scd1",
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js7",
						varName = "lock_7",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7851404,
						sizeY = 0.69336,
						image = "b#chd3",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "suo6",
							varName = "suo_7",
							posX = 0.5,
							posY = 0.525641,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1392857,
							sizeY = 0.4875002,
							image = "bg2#suo",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tis18",
							varName = "label_7",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.5632899,
							sizeY = 0.816806,
							text = "额外称号栏1",
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "js12",
						varName = "show_7",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1093589,
						sizeY = 0.3380131,
						image = "bg2#suod",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "tis7",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 4.04413,
							sizeY = 1.675499,
							text = "空",
							color = "FFF1E9D7",
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
						name = "zlt7",
						varName = "bg_7",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						lockHV = true,
						sizeX = 1.270729,
						sizeY = 0.9819116,
						image = "ch/zldw1",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "ch7",
							varName = "icon_7",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.25,
							sizeY = 0.5000001,
							image = "ch/tianxiawudi",
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
				name = "qh7",
				varName = "role_btn",
				posX = 0.9319386,
				posY = 0.7267956,
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
					text = "属性",
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
				name = "qh4",
				varName = "all_btn",
				posX = 0.4149643,
				posY = 0.7948501,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1203125,
				sizeY = 0.08055556,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.7393813,
					text = "已拥有",
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
				name = "qh5",
				varName = "equip_btn",
				posX = 0.5522543,
				posY = 0.7948501,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1203125,
				sizeY = 0.08055556,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.7393813,
					text = "奋斗中",
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
				name = "qh10",
				varName = "roleTitle_btn",
				posX = 0.9319386,
				posY = 0.5678637,
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
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "称号",
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
				name = "bz2",
				varName = "propertyBtn",
				posX = 0.8570293,
				posY = 0.8075848,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.06129244,
				sizeY = 0.09852379,
				disablePressScale = true,
				propagateToChildren = true,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "dsa5",
					posX = 0.5,
					posY = 0.3707435,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8667463,
					sizeY = 0.9585953,
					image = "chu1#sx2",
					imageNormal = "chu1#sx2",
					disableClick = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh11",
				varName = "reqBtn",
				posX = 0.9319386,
				posY = 0.4089319,
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
					name = "dsa6",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "声望",
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
				name = "qh12",
				varName = "xinjueBtn",
				posX = 0.9319386,
				posY = 0.25,
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
					name = "dsa7",
					posX = 0.499558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3136712,
					sizeY = 0.8094339,
					text = "心诀",
					color = "FFEBC6B4",
					fontSize = 26,
					fontOutlineColor = "FF51361C",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "xj_red",
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
					sizeX = 0.4859813,
					sizeY = 0.2506964,
					image = "bg2#ch",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "padzs",
				varName = "padzs",
				posX = 0.05545116,
				posY = 0.8730147,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.028125,
				sizeY = 0.1,
				image = "ty#pad1",
				effect = "",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "qh6",
				posX = 0.6895444,
				posY = 0.7948501,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.1203125,
				sizeY = 0.08055556,
				image = "chu1#fy1",
				imageNormal = "chu1#fy1",
				imagePressed = "chu1#fy2",
				imageDisable = "chu1#fy1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9027993,
					sizeY = 0.7393813,
					text = "社交称号",
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
