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
				sizeX = 0.859375,
				sizeY = 0.875,
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
					image = "b#cs",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.2,
					scale9Bottom = 0.7,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.9920635,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.24,
					sizeY = 0.08253969,
					image = "chu1#top",
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tt",
						varName = "title_name",
						posX = 0.4989172,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.5113636,
						sizeY = 0.4807692,
						image = "biaoti#bphz",
					},
				},
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "chylb",
					varName = "factionRoot",
					posX = 0.4990037,
					posY = 0.4757447,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9940227,
					sizeY = 0.9234368,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "btk",
						posX = 0.4844806,
						posY = 0.9582931,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9039778,
						sizeY = 0.09110205,
						image = "phb#top4",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "z1",
							posX = 0.1429783,
							posY = 0.498582,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1670862,
							sizeY = 1.173965,
							text = "帮派成员",
							color = "FFF1E9D7",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFA47848",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "z3",
							posX = 0.627023,
							posY = 0.4985831,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.122255,
							sizeY = 1.173965,
							text = "职务",
							color = "FFF1E9D7",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFA47848",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "z5",
							posX = 0.4827449,
							posY = 0.498583,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1741064,
							sizeY = 1.173965,
							text = "战力",
							color = "FFF1E9D7",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFA47848",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "z6",
							posX = 0.7649928,
							posY = 0.4985828,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1462932,
							sizeY = 1.173965,
							text = "线上情况",
							color = "FFF1E9D7",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFA47848",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Label",
							name = "z8",
							posX = 0.3442403,
							posY = 0.498583,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.1741064,
							sizeY = 1.173965,
							text = "职业",
							color = "FFF1E9D7",
							fontSize = 22,
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
						etype = "Image",
						name = "bpcy",
						posX = 0.4844806,
						posY = 0.5929308,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9039778,
						sizeY = 0.644626,
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
							name = "bpcyl",
							varName = "member_scroll",
							posX = 0.5,
							posY = 0.5029581,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9943516,
							sizeY = 0.9728836,
						},
					},
					},
				},
				{
					prop = {
						etype = "Label",
						name = "id2",
						varName = "count",
						posX = 0.1622465,
						posY = 0.1963401,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2538063,
						sizeY = 0.1179702,
						text = "18人",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF00152E",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "id3",
						posX = 0.3194765,
						posY = 0.1963401,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1789591,
						sizeY = 0.1179702,
						text = "拍照背景：",
						color = "FF966856",
						fontSize = 22,
						fontOutlineColor = "FF00152E",
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "an5",
						varName = "taskPhoto",
						posX = 0.5,
						posY = 0.08332458,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.159133,
						sizeY = 0.1134478,
						image = "chu1#an1",
						imageNormal = "chu1#an1",
						soundEffectClick = "audio/rxjh/UI/anniu.ogg",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "anz5",
							posX = 0.5,
							posY = 0.5338984,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9137793,
							sizeY = 1.00501,
							text = "开始合照",
							fontSize = 22,
							fontOutlineEnable = true,
							fontOutlineColor = "FFB35F1D",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Image",
							name = "xhd",
							varName = "worshipPoint",
							posX = 0.9038941,
							posY = 0.8951908,
							anchorX = 0.5,
							anchorY = 0.5,
							visible = false,
							sizeX = 0.1656441,
							sizeY = 0.4375001,
							image = "zdte#hd",
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dk3",
						posX = 0.4107553,
						posY = 0.1977419,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1545602,
						sizeY = 0.06359954,
						image = "zqxl#di1",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb10",
							varName = "gradeLabel1",
							posX = 0.4231418,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.088347,
							sizeY = 1.145833,
							text = "荣耀殿堂",
							color = "FFF1DDC1",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "dan",
							varName = "gradeBtn1",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.0431,
							sizeY = 1.376143,
							propagateToChildren = true,
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "xzan3",
								varName = "filterBtn1",
								posX = 0.8965913,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1252053,
								sizeY = 0.3731542,
								image = "zqxl#jiantou",
								imageNormal = "zqxl#jiantou",
								disablePressScale = true,
								disableClick = true,
								flippedY = true,
							},
						},
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "dk4",
						posX = 0.8499358,
						posY = 0.1977419,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1545602,
						sizeY = 0.06359954,
						image = "zqxl#di1",
						scale9 = true,
						scale9Left = 0.4,
						scale9Right = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wb11",
							varName = "gradeLabel2",
							posX = 0.4231418,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.088347,
							sizeY = 1.145833,
							text = "快速选择",
							color = "FFF1DDC1",
							fontOutlineSize = 2,
							hTextAlign = 1,
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "dan2",
							varName = "gradeBtn2",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.0431,
							sizeY = 1.376143,
							propagateToChildren = true,
						},
						children = {
						{
							prop = {
								etype = "Button",
								name = "xzan4",
								varName = "filterBtn2",
								posX = 0.8965913,
								posY = 0.5,
								anchorX = 0.5,
								anchorY = 0.5,
								sizeX = 0.1252053,
								sizeY = 0.3731542,
								image = "zqxl#jiantou",
								imageNormal = "zqxl#jiantou",
								disablePressScale = true,
								disableClick = true,
								flippedY = true,
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
				varName = "close_btn",
				posX = 0.9046776,
				posY = 0.8940439,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.05078125,
				sizeY = 0.0875,
				image = "baishi#x",
				imageNormal = "baishi#x",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "fl2",
				varName = "levelRoot2",
				posX = 0.7985808,
				posY = 0.4917208,
				anchorX = 0.5,
				anchorY = 1,
				visible = false,
				sizeX = 0.1532775,
				sizeY = 0.2260178,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "mask",
					varName = "mask2",
					posX = -0.9745561,
					posY = 0.4804368,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 7.28723,
					sizeY = 3.197059,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fl3",
					varName = "scroll2_bg",
					posX = 0.4999949,
					posY = 0.4930967,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.012623,
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
					name = "lb3",
					varName = "filterScroll2",
					posX = 0.499995,
					posY = 0.4994081,
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
				etype = "Image",
				name = "fl4",
				varName = "levelRoot1",
				posX = 0.4249762,
				posY = 0.5772531,
				anchorX = 0.5,
				anchorY = 1,
				visible = false,
				sizeX = 0.1532775,
				sizeY = 0.3115501,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "mask2",
					varName = "mask1",
					posX = 0.9336747,
					posY = 0.6673723,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 7.28723,
					sizeY = 3.197059,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "fl5",
					varName = "scroll2_bg2",
					posX = 0.4999949,
					posY = 0.4930967,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.012623,
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
					name = "lb4",
					varName = "filterScroll1",
					posX = 0.499995,
					posY = 0.4994081,
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
			etype = "Image",
			name = "d",
			varName = "mask",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			visible = false,
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
				etype = "Label",
				name = "wb",
				varName = "maskDesc",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7215127,
				sizeY = 0.5305048,
				text = "正在执行渲染，此过程消耗时间较长，请耐心等待，切勿切出游戏、切勿关闭游戏",
				color = "FFFFFF80",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "ddddd",
				posX = 0.4992199,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
