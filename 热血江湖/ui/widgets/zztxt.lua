--version = 1
local l_fileType = "node"

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
			etype = "Grid",
			name = "k1",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4953125,
			sizeY = 0.1547222,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bpsdt",
				varName = "root_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "te#hdt1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "cdd",
					varName = "Whole",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wpm",
					varName = "GoalContent",
					posX = 0.3543558,
					posY = 0.8157136,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6030737,
					sizeY = 0.3257775,
					text = "做什么任务写这里",
					color = "FF634624",
					fontSize = 22,
					fontOutlineColor = "FF16312B",
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "wpk",
					varName = "item_bg1",
					posX = 0.114292,
					posY = 0.3894693,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1041374,
					sizeY = 0.5792307,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an1",
						varName = "tipbtn1",
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
						name = "wp",
						varName = "item_icon1",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sld",
						varName = "count_bg1",
						posX = 0.5,
						posY = 0.2395833,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8526314,
						sizeY = 0.2708333,
						image = "sc#sc_sld.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo",
						varName = "item_suo1",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3684211,
						sizeY = 0.3645834,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz",
						varName = "item_count1",
						posX = 0.5257913,
						posY = 0.2199966,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylqt",
						varName = "buttomright1",
						posX = 0.4936416,
						posY = 0.5481949,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9484282,
						sizeY = 0.926211,
						scale9 = true,
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
					etype = "Image",
					name = "wpk2",
					varName = "item_bg2",
					posX = 0.2440451,
					posY = 0.3894693,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1041374,
					sizeY = 0.5792307,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an2",
						varName = "tipbtn2",
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
						name = "wp2",
						varName = "item_icon2",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sld2",
						varName = "count_bg2",
						posX = 0.5,
						posY = 0.2395833,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8526314,
						sizeY = 0.2708333,
						image = "sc#sc_sld.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo2",
						varName = "item_suo2",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3684211,
						sizeY = 0.3645834,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz2",
						varName = "item_count2",
						posX = 0.5257913,
						posY = 0.2199966,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylqt2",
						varName = "buttomright2",
						posX = 0.4936416,
						posY = 0.5481949,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9484282,
						sizeY = 0.926211,
						scale9 = true,
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
					etype = "Image",
					name = "wpk3",
					varName = "item_bg3",
					posX = 0.3737982,
					posY = 0.3894693,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1041374,
					sizeY = 0.5792307,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an3",
						varName = "tipbtn3",
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
						name = "wp3",
						varName = "item_icon3",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sld3",
						varName = "count_bg3",
						posX = 0.5,
						posY = 0.2395833,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8526314,
						sizeY = 0.2708333,
						image = "sc#sc_sld.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo3",
						varName = "item_suo3",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3684211,
						sizeY = 0.3645834,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz3",
						varName = "item_count3",
						posX = 0.5257913,
						posY = 0.2199966,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylqt3",
						varName = "buttomright3",
						posX = 0.4936416,
						posY = 0.5481949,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9484282,
						sizeY = 0.926211,
						scale9 = true,
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
					etype = "Image",
					name = "wpk4",
					varName = "item_bg4",
					posX = 0.5035512,
					posY = 0.3894693,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.1041374,
					sizeY = 0.5792307,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an4",
						varName = "tipbtn4",
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
						name = "wp4",
						varName = "item_icon4",
						posX = 0.5,
						posY = 0.538703,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "sld4",
						varName = "count_bg4",
						posX = 0.5,
						posY = 0.2395833,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8526314,
						sizeY = 0.2708333,
						image = "sc#sc_sld.png",
					},
				},
				{
					prop = {
						etype = "Image",
						name = "suo4",
						varName = "item_suo4",
						posX = 0.2062823,
						posY = 0.2403662,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3684211,
						sizeY = 0.3645834,
						image = "tb#suo",
					},
				},
				{
					prop = {
						etype = "Label",
						name = "zz4",
						varName = "item_count4",
						posX = 0.5257913,
						posY = 0.2199966,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.7744884,
						sizeY = 0.4154173,
						text = "99",
						fontSize = 18,
						fontOutlineEnable = true,
						hTextAlign = 2,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Image",
						name = "ylqt4",
						varName = "buttomright4",
						posX = 0.4936416,
						posY = 0.5481949,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.9484282,
						sizeY = 0.926211,
						scale9 = true,
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
					name = "lq",
					varName = "GetBtn",
					posX = 0.8408566,
					posY = 0.4125641,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1796947,
					sizeY = 0.392,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "lqz",
						varName = "GetBtnText",
						posX = 0.5,
						posY = 0.5323499,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8247252,
						sizeY = 1.143941,
						text = "领 取",
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
					name = "ylq",
					varName = "yilingqu",
					posX = 0.8392634,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.2144744,
					sizeY = 0.7500001,
					image = "czt#ylq",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz",
					varName = "Count",
					posX = 0.8424498,
					posY = 0.8157136,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2450573,
					sizeY = 0.541853,
					text = "2131231",
					color = "FF911D02",
					fontSize = 22,
					fontOutlineColor = "FF16312B",
					hTextAlign = 1,
					vTextAlign = 1,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
