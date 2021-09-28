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
				name = "zz",
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
				name = "dn",
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
				{
					prop = {
						etype = "Label",
						name = "jie",
						varName = "jieName",
						posX = 0.2521318,
						posY = 0.9214381,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.04721211,
						sizeY = 0.0647111,
						text = "3阶",
						color = "FF65944D",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jdtd",
					posX = 0.5,
					posY = 0.9220608,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4046095,
					sizeY = 0.04611691,
					image = "chu1#jdd",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "LoadingBar",
						name = "jdt",
						varName = "expbar",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9681942,
						sizeY = 0.8409343,
						image = "tong#jdt",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "jyz",
						varName = "expbarCount",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7763522,
						sizeY = 1.880983,
						text = "9999999/99999999",
						fontOutlineEnable = true,
						fontOutlineColor = "FF567D23",
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
					name = "sx",
					posX = 0.2442422,
					posY = 0.6919887,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.403278,
					sizeY = 0.404509,
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
						name = "dd1",
						posX = 0.5,
						posY = 0.4721245,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1.030214,
						scale9 = true,
						scale9Left = 0.45,
						scale9Right = 0.45,
						scale9Top = 0.45,
						scale9Bottom = 0.45,
						alpha = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "db",
							posX = 0.5,
							posY = 0.4795895,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9457832,
							sizeY = 0.8414726,
							image = "b#d2",
							scale9 = true,
							scale9Left = 0.4,
							scale9Right = 0.4,
							scale9Top = 0.4,
							scale9Bottom = 0.4,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zld",
							posX = 0.5,
							posY = 0.920788,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9024391,
							sizeY = 0.1720162,
							image = "chu1#zld",
							scale9 = true,
							scale9Left = 0.45,
							scale9Right = 0.45,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "la1",
							posX = 0.2642046,
							posY = 0.9142743,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5077781,
							sizeY = 0.2310943,
							text = "当前属性",
							color = "FF966856",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "la2",
							varName = "nextAttr",
							posX = 0.7312775,
							posY = 0.9142742,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.5077781,
							sizeY = 0.2310943,
							text = "下级增量",
							color = "FF966856",
							fontSize = 22,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "propsScroll",
							posX = 0.5,
							posY = 0.4478636,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.948818,
							sizeY = 0.7655699,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zs3",
							posX = 0.5729362,
							posY = 0.915029,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.03739177,
							sizeY = 0.08919552,
							image = "chu1#jt2",
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zs4",
							posX = 0.5228083,
							posY = 0.915029,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.03739177,
							sizeY = 0.08919552,
							image = "chu1#jt2",
							alpha = 0.55,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zs5",
							posX = 0.4726804,
							posY = 0.915029,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.03739177,
							sizeY = 0.08919552,
							image = "chu1#jt2",
							alpha = 0.4,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "zs6",
							posX = 0.4225526,
							posY = 0.915029,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.03739177,
							sizeY = 0.08919552,
							image = "chu1#jt2",
							alpha = 0.2,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt1",
					posX = 0.2442422,
					posY = 0.2892098,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3814135,
					sizeY = 0.3838512,
					image = "b#d5",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb1",
					varName = "scroll",
					posX = 0.2432804,
					posY = 0.2883514,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3687593,
					sizeY = 0.364917,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt2",
					posX = 0.6957221,
					posY = 0.5121024,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4996713,
					sizeY = 0.778032,
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
						name = "bj",
						posX = 0.5029534,
						posY = 0.4891289,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1.012865,
						image = "b#d5",
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
						varName = "contentScroll",
						posX = 0.5029535,
						posY = 0.4826964,
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
					name = "gb",
					varName = "close",
					posX = 0.9660424,
					posY = 0.9338391,
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
					name = "gxd",
					posX = 0.5,
					posY = 0.08227895,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.02955665,
					sizeY = 0.05172414,
					image = "chu1#gxd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "dj",
						varName = "fastAddIcon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 1.266667,
						sizeY = 1.133333,
						image = "chu1#dj",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "wbz",
						varName = "fastDesc",
						posX = 8.370163,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 14.07731,
						sizeY = 2.00528,
						text = "快速添加（拉阿拉啦啦啦啦阿里）",
						color = "FF634624",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btns",
						varName = "fastAddBtn",
						posX = 2.213582,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 5.02557,
						sizeY = 2.00528,
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
				posY = 0.8765713,
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
					image = "biaoti#fuwenzhuding",
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
			scale = {{0, {0, 0, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
