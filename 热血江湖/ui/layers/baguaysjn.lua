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
				sizeX = 0.799052,
				sizeY = 0.8184277,
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
					name = "kk4",
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
						name = "zs13",
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
						name = "zs14",
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
						etype = "Image",
						name = "dts",
						posX = 0.5,
						posY = 0.7793841,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8809267,
						sizeY = 0.3411012,
						image = "yishu#jnd",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.9693179,
					posY = 0.9393037,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05986971,
					sizeY = 0.1195944,
					image = "chu1#gb",
					imageNormal = "chu1#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb1",
					varName = "topScroll",
					posX = 0.5,
					posY = 0.7795486,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8687438,
					sizeY = 0.328683,
					horizontal = true,
					showScrollBar = false,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "d2",
					posX = 0.5,
					posY = 0.3283617,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8814206,
					sizeY = 0.536418,
					image = "b#d2",
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
						name = "lb2",
						varName = "skillScroll",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9872491,
						sizeY = 0.9743311,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "tz",
					varName = "helpBtn",
					posX = 0.9888755,
					posY = 0.1418003,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.05450824,
					sizeY = 0.1038583,
					image = "tong#bz",
					imageNormal = "tong#bz",
					disablePressScale = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "top",
				posX = 0.5,
				posY = 0.9029604,
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
					sizeX = 0.5151515,
					sizeY = 0.4807692,
					image = "biaoti#yljn",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "move_btn",
				posX = 0.05949168,
				posY = 0.865959,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07109375,
				sizeY = 0.1263889,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wbts",
				varName = "bottomDesc",
				posX = 0.5,
				posY = 0.06956163,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7032432,
				sizeY = 0.1790777,
				text = "text拖拽技能可以给每个卦位镶嵌技能，每个形状只能镶嵌对应形状的技能。",
				color = "FFFFFF80",
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
