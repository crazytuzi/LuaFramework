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
				image = "b#db1",
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
					name = "db3",
					posX = 0.5,
					posY = 0.4896554,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9749155,
					sizeY = 0.9669259,
					image = "b#db3",
					scale9 = true,
					scale9Left = 0.47,
					scale9Right = 0.47,
					scale9Top = 0.47,
					scale9Bottom = 0.47,
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "fy",
					varName = "amuletRoot",
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
						name = "g4",
						posX = 0.3383327,
						posY = 0.4926496,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6117396,
						sizeY = 0.8908672,
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
							etype = "Image",
							name = "fuyin1",
							posX = 0.4620994,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.9152185,
							sizeY = 0.9998248,
							image = "zfsbj#fuyinbeijing1",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "fuyin2",
								posX = 0.5,
								posY = 0.4999999,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1,
								sizeY = 1,
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
									name = "fy1",
									varName = "amuletBg1",
									posX = 0.218013,
									posY = 0.7776567,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										name = "bj",
										varName = "levelBg1",
										posX = 0.492342,
										posY = -0.2132482,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj1",
											varName = "level1",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.1319934,
									posY = 0.5157487,
									anchorX = 0.5,
									anchorY = 0.5,
									lockHV = true,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj2",
										varName = "levelBg2",
										posX = 0.492342,
										posY = -0.226512,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj3",
											varName = "level2",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz2",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.3491856,
									posY = 0.6291519,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj4",
										varName = "levelBg3",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj5",
											varName = "level3",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz3",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.5027231,
									posY = 0.7923077,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
									image = "zfsbj#shitoucao",
								},
								children = {
								{
									prop = {
										etype = "Image",
										name = "fya4",
										varName = "amuletLock4",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj6",
										varName = "levelBg4",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj7",
											varName = "level4",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz4",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.7831925,
									posY = 0.7782015,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj8",
										varName = "levelBg5",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj9",
											varName = "level5",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz5",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.6525159,
									posY = 0.6298484,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj10",
										varName = "levelBg6",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj11",
											varName = "level6",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz6",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.348203,
									posY = 0.4066146,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj12",
										varName = "levelBg7",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj13",
											varName = "level7",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz7",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.4994436,
									posY = 0.2705565,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj14",
										varName = "levelBg8",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj15",
											varName = "level8",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz8",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.2169477,
									posY = 0.2569351,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj16",
										varName = "levelBg9",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj17",
											varName = "level9",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz9",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.8697457,
									posY = 0.5158826,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj18",
										varName = "levelBg10",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj19",
											varName = "level10",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz10",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.7836835,
									posY = 0.2558397,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj20",
										varName = "levelBg11",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj21",
											varName = "level11",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz11",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.6561536,
									posY = 0.4052508,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj22",
										varName = "levelBg12",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj23",
											varName = "level12",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz12",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.0829,
									posY = 0.69,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj22",
										varName = "levelBg13",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj24",
											varName = "level13",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz13",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.9159,
									posY = 0.69,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj25",
										varName = "levelBg14",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj26",
											varName = "level14",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz14",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.0829,
									posY = 0.342,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj27",
										varName = "levelBg15",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj28",
											varName = "level15",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz15",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.9159,
									posY = 0.342,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj29",
										varName = "levelBg16",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj30",
											varName = "level16",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz16",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
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
									posX = 0.5,
									posY = 0.525,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.1174967,
									sizeY = 0.1292463,
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
										sizeX = 0.7151827,
										sizeY = 0.6768692,
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
										name = "bj31",
										varName = "levelBg17",
										posX = 0.492342,
										posY = -0.1533414,
										anchorX = 0.5,
										anchorY = 0.5,
										sizeX = 1.074698,
										sizeY = 0.2887066,
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
											name = "bj32",
											varName = "level17",
											posX = 0.5,
											posY = 0.5,
											anchorX = 0.5,
											anchorY = 0.5,
											sizeX = 0.7944031,
											sizeY = 1.504492,
											text = "5级",
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
										name = "xz17",
										posX = 0.5,
										posY = 0.5,
										anchorX = 0.5,
										anchorY = 0.5,
										visible = false,
										lockHV = true,
										sizeX = 1.235171,
										sizeY = 1.23517,
										image = "zfsbj#dianji",
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
				{
					prop = {
						etype = "Image",
						name = "g5",
						posX = 0.7884749,
						posY = 0.4920708,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3546578,
						sizeY = 0.9040512,
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
						alpha = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "g6",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							image = "d2#dw2",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "g7",
								posX = 0.5,
								posY = 0.9300194,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.5166987,
								sizeY = 0.06865647,
								image = "chu1#top2",
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "g8",
									posX = 0.5,
									posY = 0.4915047,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.6,
									sizeY = 1.109286,
									text = "符印属性",
									fontOutlineEnable = true,
									fontOutlineColor = "FFA47848",
									fontOutlineSize = 2,
									hTextAlign = 1,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Scroll",
								name = "lb2",
								varName = "alumetPropScroll",
								posX = 0.5,
								posY = 0.4451744,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9540481,
								sizeY = 0.8507091,
								showScrollBar = false,
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zl",
						posX = 0.3151474,
						posY = 0.8624047,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2388889,
						sizeY = 0.07732074,
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
							name = "zl2",
							varName = "power",
							posX = 0.7619129,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6964514,
							sizeY = 1.202154,
							text = "100000",
							color = "FFFFD97F",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFA47848",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zhan",
							posX = 0.3147174,
							posY = 0.544597,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.1443464,
							sizeY = 0.7135526,
							image = "tong#zl",
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "ckyj",
						varName = "suitBtn",
						posX = 0.3151474,
						posY = 0.1023331,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1714286,
						sizeY = 0.1137931,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "ckyj1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8606537,
							sizeY = 0.8021038,
							text = "查看言诀",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF2A6953",
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
				posY = 0.894627,
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
					name = "top1",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3787879,
					sizeY = 0.4807692,
					image = "biaoti#paixingbang",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.88379,
				posY = 0.8544155,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.053125,
				sizeY = 0.1055556,
				image = "baishi#x",
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
