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
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
					name = "jd1",
					posX = 0.5,
					posY = 0.5068964,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "db1",
						posX = 0.5,
						posY = 0.442392,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8921295,
						sizeY = 0.7591462,
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
							etype = "Image",
							name = "dah",
							posX = 0.5,
							posY = 1.044124,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.1362692,
							image = "b#btd",
							scale9 = true,
							scale9Left = 0.3,
							scale9Right = 0.4,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "x1",
								posX = 0.1552336,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.004,
								sizeY = 0.9016396,
								image = "b#shuxian",
							},
						},
						{
							prop = {
								etype = "Image",
								name = "x3",
								posX = 0.5785379,
								posY = 0.4999996,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.004,
								sizeY = 0.9016396,
								image = "b#shuxian",
							},
						},
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.5,
							posY = 0.4890931,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9887726,
							sizeY = 0.9672678,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "btk",
							posX = 0.5,
							posY = 1.043258,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 0.1196078,
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
							alpha = 0.3,
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "btk1",
								posX = 0.07932863,
								posY = 0.5164594,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.16,
								sizeY = 1.016394,
								scale9 = true,
								scale9Left = 0.4,
								scale9Right = 0.4,
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "z1",
									posX = 0.5,
									posY = 0.4999999,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.740453,
									sizeY = 0.8444229,
									text = "排 名",
									color = "FF966856",
									fontSize = 24,
									fontOutlineColor = "FF143230",
									hTextAlign = 1,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Image",
								name = "btk2",
								posX = 0.2914031,
								posY = 0.5164595,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.28,
								sizeY = 1.016394,
								scale9 = true,
								scale9Left = 0.4,
								scale9Right = 0.4,
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "z2",
									posX = 0.7726906,
									posY = 0.4999999,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 1.285834,
									sizeY = 0.8444229,
									text = "名 称",
									color = "FF966856",
									fontSize = 24,
									fontOutlineColor = "FF143230",
									hTextAlign = 1,
									vTextAlign = 1,
								},
							},
							},
						},
						{
							prop = {
								etype = "Image",
								name = "btk5",
								posX = 0.8641685,
								posY = 0.5164594,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.273084,
								sizeY = 1.016394,
								scale9 = true,
								scale9Left = 0.4,
								scale9Right = 0.4,
							},
							children = {
							{
								prop = {
									etype = "Label",
									name = "z5",
									posX = 0.2182766,
									posY = 0.5,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 1.3039,
									sizeY = 0.8444229,
									text = "伤害量",
									color = "FF966856",
									fontSize = 24,
									fontOutlineColor = "FF143230",
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
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.965556,
					posY = 0.933779,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
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
				posY = 0.8765713,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.20625,
				sizeY = 0.07222223,
				image = "chu1#top",
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "td2",
					posX = 0.4988506,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3787879,
					sizeY = 0.4807692,
					image = "jjc#jjc_phb.png",
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
