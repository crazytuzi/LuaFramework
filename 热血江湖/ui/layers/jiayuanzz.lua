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
					sizeX = 0.8453202,
					sizeY = 0.9758621,
					image = "jydb#jydb",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dws",
						posX = 0.5,
						posY = 0.4707988,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8969209,
						sizeY = 0.6929284,
						image = "b#jyd",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.8922829,
					posY = 0.944153,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05221675,
					sizeY = 0.08793104,
					image = "rydt#gb",
					imageNormal = "rydt#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
						etype = "Image",
						name = "d2",
						posX = 0.480296,
						posY = 0.469919,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1280788,
						sizeY = 0.6007355,
						image = "wh#fgx",
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "qh4",
						varName = "all_btn",
						posX = 0.2099639,
						posY = 0.820823,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.129064,
						sizeY = 0.1,
						image = "jy#yq2",
						imageNormal = "jy#yq2",
						imagePressed = "jy#yq1",
						imageDisable = "jy#yq2",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "hz",
							varName = "textBtn1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.210658,
							sizeY = 1.202088,
							text = "花草",
							color = "FFFFC198",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF9B3D46",
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
						varName = "flower_btn",
						posX = 0.3436994,
						posY = 0.820823,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.129064,
						sizeY = 0.1,
						image = "jy#yq2",
						imageNormal = "jy#yq2",
						imagePressed = "jy#yq1",
						imageDisable = "jy#yq2",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "hz2",
							varName = "textBtn2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.210658,
							sizeY = 1.202088,
							text = "树木",
							color = "FFFFC198",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF9B3D46",
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
						name = "qh6",
						varName = "tree_btn",
						posX = 0.477435,
						posY = 0.820823,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.129064,
						sizeY = 0.1,
						image = "jy#yq2",
						imageNormal = "jy#yq2",
						imagePressed = "jy#yq1",
						imageDisable = "jy#yq2",
						disablePressScale = true,
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "hz3",
							varName = "textBtn3",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.210658,
							sizeY = 1.202088,
							text = "瓜果蔬菜",
							color = "FFFFC198",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FF9B3D46",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Grid",
						name = "jie",
						posX = 0.7026219,
						posY = 0.469919,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3108187,
						sizeY = 0.5869663,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "db",
							posX = 0.5569715,
							posY = 0.8497388,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7005177,
							sizeY = 0.1746667,
							image = "d2#xhd",
						},
						children = {
						{
							prop = {
								etype = "Image",
								name = "djk",
								varName = "grade_icon",
								posX = 0.01211041,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								lockHV = true,
								sizeX = 0.3846153,
								sizeY = 1.429446,
								image = "djk#ktong",
							},
							children = {
							{
								prop = {
									etype = "Image",
									name = "dkt",
									varName = "curIcon",
									posX = 0.5058479,
									posY = 0.5145587,
									anchorX = 0.5,
									anchorY = 0.5,
									sizeX = 0.810432,
									sizeY = 0.8221794,
								},
							},
							},
						},
						},
					},
					{
						prop = {
							etype = "Label",
							name = "mc",
							varName = "tip_name",
							posX = 0.7183454,
							posY = 0.8465904,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.25,
							text = "苹果",
							color = "FFF1691E",
							fontSize = 24,
							fontOutlineEnable = true,
							fontOutlineColor = "FFF2D8BD",
							fontOutlineSize = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "plcs2",
							varName = "plant_btn",
							posX = 0.5,
							posY = 0.1112687,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.501399,
							sizeY = 0.1762423,
							image = "chu1#an2",
							imageNormal = "chu1#an2",
							soundEffectClick = "audio/rxjh/UI/anniu.ogg",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "ys4",
								posX = 0.5,
								posY = 0.5454545,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.9120977,
								sizeY = 1.156784,
								text = "种 植",
								fontSize = 22,
								fontOutlineEnable = true,
								fontOutlineColor = "FF347468",
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
							name = "dw1",
							posX = 0.5,
							posY = 0.6556821,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9491022,
							sizeY = 0.102808,
							image = "jy#tiao",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "ms1",
								varName = "t_level",
								posX = 0.3885792,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6560435,
								sizeY = 1.826496,
								text = "作物等级：",
								color = "FF924033",
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "ms2",
								varName = "level",
								posX = 0.6142352,
								posY = 0.4999995,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4383814,
								sizeY = 1.826496,
								text = "1",
								color = "FF924033",
								hTextAlign = 2,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dw2",
							posX = 0.4999999,
							posY = 0.504627,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9491022,
							sizeY = 0.102808,
							image = "jy#tiao",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "ms3",
								varName = "t_needTime",
								posX = 0.3885792,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6560435,
								sizeY = 1.826496,
								text = "成熟周期：",
								color = "FF924033",
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "ms4",
								varName = "needTime",
								posX = 0.6142352,
								posY = 0.4999995,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4383814,
								sizeY = 1.826496,
								text = "1",
								color = "FF924033",
								hTextAlign = 2,
								vTextAlign = 1,
							},
						},
						},
					},
					{
						prop = {
							etype = "Image",
							name = "dw3",
							posX = 0.4999999,
							posY = 0.3535719,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9491022,
							sizeY = 0.102808,
							image = "jy#tiao",
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "ms5",
								varName = "t_produce",
								posX = 0.3885792,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.6560435,
								sizeY = 1.826496,
								text = "作物产量：",
								color = "FF924033",
								vTextAlign = 1,
							},
						},
						{
							prop = {
								etype = "Label",
								name = "ms6",
								varName = "produce",
								posX = 0.6142352,
								posY = 0.4999995,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.4383814,
								sizeY = 1.826496,
								text = "1",
								color = "FF924033",
								hTextAlign = 2,
								vTextAlign = 1,
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Scroll",
						name = "lb",
						varName = "item_scroll",
						posX = 0.3411469,
						posY = 0.4673376,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3865567,
						sizeY = 0.5749167,
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
				posY = 0.8376821,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5304688,
				sizeY = 0.1236111,
				image = "jy#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
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
	gy2 = {
	},
	gy3 = {
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_dakai2 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
