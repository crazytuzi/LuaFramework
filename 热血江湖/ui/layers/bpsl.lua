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
				posX = 0.5000001,
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
				name = "kk2",
				posX = 0.5,
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7929688,
				sizeY = 0.8055556,
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
				etype = "Image",
				name = "zhuxian",
				varName = "otherRoot",
				posX = 0.4992188,
				posY = 0.4986111,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.75,
				sizeY = 0.7619047,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "mhd3",
					posX = 0.1751235,
					posY = 0.3343883,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2899288,
					sizeY = 0.6224149,
					image = "b#d2",
					scale9 = true,
					scale9Left = 0.3,
					scale9Right = 0.3,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "nr2",
						varName = "taskPartDesc",
						posX = 0.4972305,
						posY = 0.632892,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9338033,
						sizeY = 0.5113959,
						text = "任务的章节内容描述文字",
						color = "FF96765C",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tiao1",
						posX = 0.5,
						posY = 0.2309658,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.095815,
						sizeY = 0.1025073,
						image = "bp#tiao",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "nr12",
							varName = "scheduleTxt",
							posX = 0.5936462,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8655577,
							sizeY = 1.230891,
							text = "拓展进度：0/1",
							color = "FFFFE42E",
							fontSize = 22,
							vTextAlign = 1,
						},
					},
					},
				},
				{
					prop = {
						etype = "Image",
						name = "tiao2",
						posX = 0.5,
						posY = 0.1020986,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.095815,
						sizeY = 0.1025073,
						image = "bp#tiao",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "nr13",
							varName = "honor",
							posX = 0.5936462,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.8655577,
							sizeY = 1.230891,
							text = "拓展进度：0/1",
							color = "FFFFE42E",
							fontSize = 22,
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
					name = "mhd4",
					posX = 0.6335781,
					posY = 0.1241881,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5562513,
					sizeY = 0.220213,
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
						name = "nr14",
						varName = "stageTxt",
						posX = 0.411109,
						posY = 0.7272394,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7471671,
						sizeY = 0.4549147,
						text = "本阶段完成进度：15/21",
						color = "FF3B8157",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "nr15",
						varName = "timeTxt",
						posX = 0.411109,
						posY = 0.3966076,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7471671,
						sizeY = 0.4549147,
						text = "评定计时：3天",
						color = "FFB67D32",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "nr16",
						varName = "quickDesc",
						posX = 0.5497919,
						posY = 0.06597547,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.024533,
						sizeY = 0.4549147,
						text = "活跃度达到x以后可以花费绑元快速完成任务",
						color = "FF3B8157",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mhd",
					varName = "dtImg",
					posX = 0.1734685,
					posY = 0.7746777,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.31325,
					sizeY = 0.3263021,
					image = "dt2#hongluopingyuan",
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
						name = "sbwk2",
						varName = "icon",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1,
						sizeY = 1,
						scale9Left = 0.3,
						scale9Right = 0.3,
						scale9Top = 0.3,
						scale9Bottom = 0.3,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "ljwcan3",
					varName = "otherDoBtn",
					posX = 0.8357593,
					posY = 0.1092747,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.18125,
					sizeY = 0.1203125,
					image = "chu1#an1",
					imageNormal = "chu1#an1",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "ljwc3",
						varName = "b",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9512753,
						sizeY = 0.7937737,
						text = "找人代做",
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
					etype = "Button",
					name = "bz",
					varName = "helpBtn",
					posX = 1.003344,
					posY = 0.125094,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.06354167,
					sizeY = 0.1203125,
					image = "tong#bz",
					imageNormal = "tong#bz",
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d5",
					posX = 0.6513137,
					posY = 0.5809917,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6125335,
					sizeY = 0.7115973,
					image = "b#d5",
					scale9 = true,
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
						sizeX = 0.99,
						sizeY = 0.99,
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
					sizeX = 0.5113636,
					sizeY = 0.4807692,
					image = "biaoti#bpsl",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.8691311,
				posY = 0.8287812,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05234375,
				sizeY = 0.1055556,
				image = "chu1#gb",
				imageNormal = "chu1#gb",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "ts",
				posX = 0.5,
				posY = 0.060441,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "商路任务每天18点刷新",
				hTextAlign = 1,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.1, 1.1, 1}}, {200, {1,1,1}}, },
		},
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
