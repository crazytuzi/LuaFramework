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
						posX = 0.4844976,
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
						etype = "Image",
						name = "g2",
						posX = 0.6947575,
						posY = 0.5018612,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4485335,
						sizeY = 0.7243496,
						image = "b#d3",
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
							name = "lb",
							varName = "recordScroll",
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
							etype = "Label",
							name = "jf",
							varName = "shareScore",
							posX = 0.6982325,
							posY = -0.08570322,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.25,
							text = "我的积分：2000",
							color = "FF966856",
							hTextAlign = 2,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "RichText",
							name = "sqsl",
							varName = "applyDesc",
							posX = 0.3048246,
							posY = -0.08570322,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.6,
							sizeY = 0.25,
							text = "我的申请：3杠5",
							color = "FF966856",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "ckan",
							varName = "personalFilterBtn",
							posX = 0.4715033,
							posY = -0.0841253,
							anchorX = 0.5,
							anchorY = 0.5,
							lockHV = true,
							sizeX = 0.2348026,
							sizeY = 0.1239581,
							image = "chu1#sn1",
							imageNormal = "chu1#sn1",
							disablePressScale = true,
						},
						children = {
						{
							prop = {
								etype = "Label",
								name = "hz3",
								varName = "personalFilterDesc",
								posX = 0.5,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 1.053439,
								sizeY = 1.145929,
								text = "筛 选",
								color = "FF966856",
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
				{
					prop = {
						etype = "Image",
						name = "dwt",
						posX = 0.2394329,
						posY = 0.5076694,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4306408,
						sizeY = 0.9654453,
						image = "d2#dw2",
						scale9 = true,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lie",
							varName = "itemScroll",
							posX = 0.5040659,
							posY = 0.4856198,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9644529,
							sizeY = 0.9415356,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "bz",
						varName = "ruleBtn",
						posX = 0.9760603,
						posY = 0.1557651,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06009853,
						sizeY = 0.1185215,
						image = "tong#bz",
						imageNormal = "tong#bz",
						disablePressScale = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tj1",
						varName = "selectGradeRoot",
						posX = 0.552117,
						posY = 0.9141645,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1635468,
						sizeY = 0.08619745,
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
							varName = "gradeBtn",
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
								posX = 0.8978875,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.2590362,
								sizeY = 0.9166666,
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
							varName = "gradeLabel",
							posX = 0.4174764,
							posY = 0.5221087,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7650473,
							sizeY = 1,
							text = "全部记录",
							color = "FFFFF0D5",
							fontSize = 22,
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
						varName = "applyRecordBtn",
						posX = 0.8529829,
						posY = 0.9160702,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.1307967,
						sizeY = 0.08978901,
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
							posY = 0.5172414,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.053439,
							sizeY = 0.7393813,
							text = "申请列表",
							color = "FF966856",
							fontSize = 22,
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
						etype = "Image",
						name = "fl2",
						varName = "levelRoot",
						posX = 0.5531022,
						posY = 0.8603835,
						anchorX = 0.5,
						anchorY = 1,
						visible = false,
						sizeX = 0.1655173,
						sizeY = 0.3681349,
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
							name = "lb2",
							varName = "filterScroll",
							posX = 0.5,
							posY = 0.5292683,
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
					name = "gb",
					varName = "close",
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
					posY = 0.4996001,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5113636,
					sizeY = 0.4807692,
					image = "biaoti#bpck",
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
