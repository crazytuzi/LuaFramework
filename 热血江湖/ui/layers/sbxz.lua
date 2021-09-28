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
					name = "db1",
					posX = 0.4993053,
					posY = 0.3896513,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9024167,
					sizeY = 0.5985172,
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
						name = "lbt1",
						varName = "scroll",
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
					name = "tx1",
					varName = "petRoot1",
					posX = 0.4256865,
					posY = 0.8197643,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1370354,
					sizeY = 0.2068966,
					image = "dw#dw_txd.png",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an1",
						varName = "petBtn1",
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
						name = "txd1",
						varName = "petIconBg1",
						posX = 0.4625,
						posY = 0.4712229,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6830064,
						sizeY = 0.7999998,
						image = "shen#sbd",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txt1",
							varName = "petIcon1",
							posX = 0.5081546,
							posY = 0.5490907,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7566569,
							sizeY = 0.7395833,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z1",
					varName = "tips_desc",
					posX = 0.5167508,
					posY = 0.06450967,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.08427987,
					text = "请选择在[神兵乱战]玩法中使用的神兵",
					color = "FF966856",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dw",
					posX = 0.3195885,
					posY = 0.8582447,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2049261,
					sizeY = 0.07413793,
					image = "dw#mjd",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "zl2",
						varName = "powerLabel",
						posX = 0.4232862,
						posY = -1.064459,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7873148,
						sizeY = 1.520377,
						text = "999999",
						color = "FFC93034",
						fontSize = 26,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "zdl",
						posX = 0.4232862,
						posY = 0.4984187,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3894231,
						sizeY = 0.8604651,
						image = "dw#zl",
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xian",
					posX = 0.343362,
					posY = 0.8144526,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.00295928,
					sizeY = 0.2362832,
					image = "b#xian",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wjtxd",
					varName = "headBg",
					posX = 0.1582973,
					posY = 0.8165751,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1448276,
					sizeY = 0.2034483,
					image = "zdtx#txd.png",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "heroIcon",
						posX = 0.5054789,
						posY = 0.6925332,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7210885,
						sizeY = 1.110169,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "wjdj",
						posX = 0.8479171,
						posY = 0.2300532,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2857142,
						sizeY = 0.3644067,
						image = "zdte#djd2",
					},
					children = {
					{
						prop = {
							etype = "Label",
							name = "wjd",
							varName = "heroLvl",
							posX = 0.5,
							posY = 0.5,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.9873805,
							sizeY = 0.7730079,
							text = "100",
							fontOutlineEnable = true,
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
					etype = "Button",
					name = "bc",
					varName = "saveBtn",
					posX = 0.8830842,
					posY = 0.8201236,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1182266,
					sizeY = 0.2051724,
					image = "jjcc#bc",
					imageNormal = "jjcc#bc",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "closeBtn",
					posX = 0.965085,
					posY = 0.9337791,
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
			{
				prop = {
					etype = "Image",
					name = "tx2",
					posX = 0.5806481,
					posY = 0.8197643,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1370354,
					sizeY = 0.2068966,
					image = "dw#dw_txd.png",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an2",
						varName = "petBtn2",
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
						name = "txd2",
						varName = "petIconBg2",
						posX = 0.4625,
						posY = 0.4712229,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6830064,
						sizeY = 0.7999998,
						image = "shen#sbd",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txt2",
							varName = "petIcon2",
							posX = 0.5081546,
							posY = 0.5490907,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7566569,
							sizeY = 0.7395833,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tx3",
					posX = 0.7356098,
					posY = 0.8197643,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1370354,
					sizeY = 0.2068966,
					image = "dw#dw_txd.png",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an3",
						varName = "petBtn3",
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
						name = "txd3",
						varName = "petIconBg3",
						posX = 0.4625,
						posY = 0.4712229,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.6830064,
						sizeY = 0.7999998,
						image = "shen#sbd",
					},
					children = {
					{
						prop = {
							etype = "Image",
							name = "txt3",
							varName = "petIcon3",
							posX = 0.5081546,
							posY = 0.5490907,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.7566569,
							sizeY = 0.7395833,
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
				posY = 0.8779602,
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
					image = "biaoti#xzsb",
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
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
