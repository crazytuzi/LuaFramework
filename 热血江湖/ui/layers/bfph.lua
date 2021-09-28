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
			scale9Left = 0.4,
			scale9Right = 0.4,
			scale9Top = 0.4,
			scale9Bottom = 0.4,
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
				name = "db",
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
					etype = "Image",
					name = "lbd",
					posX = 0.4844384,
					posY = 0.4565738,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8947265,
					sizeY = 0.8058286,
					image = "b#d5",
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
						name = "lb2",
						varName = "item_scroll",
						posX = 0.4987802,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9875437,
						sizeY = 0.9803653,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.4838198,
					posY = 0.8965724,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8980983,
					sizeY = 0.1034483,
					image = "b#btd",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "z1",
						posX = 0.1561957,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.225537,
						sizeY = 1.015651,
						text = "排名",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "z2",
						posX = 0.3842771,
						posY = 0.4999995,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.225537,
						sizeY = 1.015651,
						text = "角色名称",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "z4",
						posX = 0.8942718,
						posY = 0.4999995,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.225537,
						sizeY = 1.015651,
						text = "伤害量",
						color = "FF966856",
						fontSize = 22,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "x1",
						posX = 0.1867698,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.003291026,
						sizeY = 0.8999998,
						image = "b#shuxian",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "x2",
						posX = 0.6,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.003291026,
						sizeY = 0.8999998,
						image = "b#shuxian",
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
					etype = "Button",
					name = "yq1",
					varName = "single_btn",
					posX = 0.9690263,
					posY = 0.7448585,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.09753694,
					sizeY = 0.2637931,
					image = "tong#yq1",
					imageNormal = "tong#yq1",
					imagePressed = "chu1#yq2",
					imageDisable = "tong#yq1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "yz1",
						posX = 0.4995593,
						posY = 0.5204018,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2861022,
						sizeY = 0.809434,
						text = "单次伤害",
						color = "FFEBC6B4",
						fontSize = 22,
						fontOutlineColor = "FF51361C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
						lineSpaceAdd = -2,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "yq2",
					varName = "all_btn",
					posX = 0.9690263,
					posY = 0.5405981,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09753694,
					sizeY = 0.2637931,
					image = "tong#yq1",
					imageNormal = "tong#yq1",
					imagePressed = "chu1#yq2",
					imageDisable = "tong#yq1",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "yz2",
						posX = 0.4995581,
						posY = 0.5204018,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2861022,
						sizeY = 0.809434,
						text = "累积伤害",
						color = "FFEBC6B4",
						fontSize = 22,
						fontOutlineColor = "FF51361C",
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
						lineSpaceAdd = -2,
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
				posY = 0.8774563,
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
					name = "tt2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.5113636,
					sizeY = 0.4807692,
					image = "biaoti#shpm",
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
