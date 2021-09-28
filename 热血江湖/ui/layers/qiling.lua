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
						posX = 0.5,
						posY = 0.4921793,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9540589,
						sizeY = 0.959002,
						image = "b#db3",
						scale9 = true,
						scale9Left = 0.47,
						scale9Right = 0.47,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zzs1",
						posX = 1.022309,
						posY = 0.5671327,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.05714285,
						sizeY = 0.837931,
						image = "qiling#zs1",
						alpha = 0.7,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zzs2",
						posX = -0.022309,
						posY = 0.5671327,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.05714285,
						sizeY = 0.837931,
						image = "qiling#zs1",
						alpha = 0.7,
						flippedX = true,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zzs3",
						posX = -0.01932751,
						posY = 0.2297544,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1418719,
						sizeY = 0.4465517,
						image = "qiling#zs2",
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
					posY = 0.5051723,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "g2",
						posX = 0.5000001,
						posY = 0.5109699,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8995073,
						sizeY = 0.7758621,
						image = "qilingbj#qilingbj",
						scale9Left = 0.4,
						scale9Right = 0.4,
						scale9Top = 0.4,
						scale9Bottom = 0.4,
					},
					children = {
					{
						prop = {
							etype = "Scroll",
							name = "lb",
							varName = "scroll",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 1,
							sizeY = 1,
							horizontal = true,
							showScrollBar = false,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "bjt",
						posX = 0.5059112,
						posY = 0.4586523,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.158621,
						sizeY = 0.9293103,
						image = "qilingk#qilingk",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "ts",
						posX = 0.5167484,
						posY = 0.07192752,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.6609827,
						sizeY = 0.1146291,
						text = "点击器灵头像进行修炼",
						color = "FF966856",
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "bz",
						varName = "helpBtn",
						posX = 0.9997025,
						posY = 0.1540247,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.06009852,
						sizeY = 0.1137931,
						image = "tong#bz",
						imageNormal = "tong#bz",
						disablePressScale = true,
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
					posY = 0.9338251,
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
					name = "jt",
					posX = 0.9800324,
					posY = 0.5241374,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.03940887,
					sizeY = 0.05172414,
					image = "chongyangjie#jt",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.8737935,
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
					sizeX = 0.3181818,
					sizeY = 0.4807692,
					image = "biaoti#qiling",
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
	ss = {
		jt = {
			alpha = {{0, {1300}}, {700, {0}}, {1300, {1}}, },
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
		{0,"ss", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
