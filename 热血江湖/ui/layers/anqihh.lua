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
				name = "dt2",
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
						name = "zs5",
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
						name = "zs6",
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
					etype = "Image",
					name = "dmzyt",
					varName = "imageView",
					posX = 0.2850981,
					posY = 0.4888182,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.4492611,
					sizeY = 0.8827586,
					image = "sbtjdmzy#sbtjdmzy",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "z1",
					varName = "moxingbg",
					posX = 0.2826771,
					posY = 0.4793734,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.4583079,
					sizeY = 0.9296713,
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
						name = "dz",
						posX = 0.4871018,
						posY = 0.5203297,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.100643,
						sizeY = 0.8178642,
						image = "anqibj#anqibj",
					},
				},
				{
					prop = {
						etype = "Sprite3D",
						name = "mx2",
						varName = "hero_module",
						posX = 0.493523,
						posY = 0.25,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.4464025,
						sizeY = 0.5950876,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "biaoq",
						varName = "tipsImg1",
						posX = 0.847679,
						posY = 0.8314227,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2902087,
						sizeY = 0.06490985,
						image = "bgchu#dazuo",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "btn1",
							varName = "tipsBtn1",
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
						etype = "Image",
						name = "biaoq2",
						varName = "tipsImg2",
						posX = 0.847679,
						posY = 0.7444008,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2902087,
						sizeY = 0.06490985,
						image = "bgchu#dazuo",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "btn2",
							varName = "tipsBtn2",
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
						etype = "Image",
						name = "biaoq3",
						varName = "tipsImg3",
						posX = 0.847679,
						posY = 0.6573789,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2902087,
						sizeY = 0.06490985,
						image = "bgchu#dazuo",
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "btn3",
							varName = "tipsBtn3",
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
						etype = "Image",
						name = "gxd",
						varName = "markRoot",
						posX = 0.3111275,
						posY = 0.07222765,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06449082,
						sizeY = 0.05563702,
						image = "chu1#gxd",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "dj",
							varName = "markImg",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1.266667,
							sizeY = 1.133333,
							image = "chu1#dj",
						},
					},
					{
						prop = {
							etype = "Label",
							name = "tsz",
							posX = 5.823422,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 8.784198,
							sizeY = 2.121467,
							text = "使用幻化形象",
							color = "FF966856",
							vTextAlign = 1,
						},
					},
					{
						prop = {
							etype = "Button",
							name = "gxan",
							varName = "markBtn",
							posX = 2.41138,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 5.622749,
							sizeY = 1.522448,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tsa",
						posX = 0.5,
						posY = 0.955474,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.659956,
						sizeY = 0.07789183,
						image = "bs#top",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "mc",
						varName = "name",
						posX = 0.5,
						posY = 0.9499465,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6,
						sizeY = 0.25,
						text = "暴雨梨花针",
						color = "FFF8EBA3",
						fontSize = 24,
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
					name = "sx",
					posX = 0.7345859,
					posY = 0.4974229,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4416422,
					sizeY = 0.8830308,
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
						etype = "Image",
						name = "dw1",
						posX = 0.5,
						posY = 0.5126957,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 0.6042573,
						image = "d#bt",
						scale9 = true,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
						alpha = 0.7,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "effectScroll",
							posX = 0.4942124,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9135874,
							sizeY = 0.9572747,
						},
					},
					},
				},
				{
					prop = {
						etype = "Button",
						name = "btn",
						varName = "jihuo_btn",
						posX = 0.5,
						posY = 0.1073886,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3881617,
						sizeY = 0.1288665,
						image = "chu1#an2",
						imageNormal = "chu1#an2",
						disablePressScale = true,
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "btnz",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7256508,
							sizeY = 0.8432468,
							text = "激 活",
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
						name = "yjh",
						varName = "jihuo_img",
						posX = 0.4977692,
						posY = 0.1082694,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.312314,
						sizeY = 0.09567363,
						image = "sbtj#yjh",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bgt",
						posX = 0.5,
						posY = 0.9092529,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6223971,
						sizeY = 0.09762616,
						image = "chu1#zld",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "zl",
							varName = "battle_power",
							posX = 0.5930341,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7138616,
							sizeY = 1.061954,
							text = "455546",
							color = "FFFFE7AF",
							fontSize = 24,
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
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close_btn",
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
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "revolve",
					posX = 0.2660043,
					posY = 0.512049,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3324591,
					sizeY = 0.7986879,
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
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#anqihuanhua",
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
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
	},
	kuang = {
		kuang = {
			alpha = {{0, {0.5}}, {500, {1}}, {1000, {0.5}}, },
		},
	},
	l = {
		l = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l2 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	l2 = {
		l3 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l4 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	kuang2 = {
		kuang2 = {
			alpha = {{0, {0.5}}, {500, {1}}, {1000, {0.5}}, },
		},
	},
	l3 = {
		l5 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l6 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
	},
	l4 = {
		l7 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
		},
		l8 = {
			alpha = {{0, {0}}, {400, {0}}, {500, {2}}, {600, {0}}, {1000, {0}}, },
			rotate = {{0, {0}}, {500, {180}}, },
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
	c_kuang = {
		{0,"kuang", -1, 0},
		{2,"lizi", 1, 0},
		{2,"lizi2", 1, 0},
		{2,"lizi3", 1, 0},
		{2,"lizi4", 1, 0},
		{0,"l", -1, 0},
		{0,"l2", -1, 500},
	},
	c_kuang2 = {
		{2,"lizi5", 1, 0},
		{2,"lizi6", 1, 0},
		{2,"lizi7", 1, 0},
		{2,"lizi8", 1, 0},
		{0,"kuang2", -1, 0},
		{0,"l3", -1, 0},
		{0,"l4", -1, 500},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
