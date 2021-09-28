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
			etype = "Image",
			name = "djk1",
			posX = 0.5,
			posY = 0.4948886,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3470857,
			sizeY = 0.2255007,
			image = "b#lbt",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.7,
			scale9Top = 0.5,
			scale9Bottom = 0.3,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cdg3",
				posX = 0.4994253,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.006752654,
				sizeY = 0.92,
				image = "b#shuxian",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db2",
				posX = 0.235981,
				posY = 0.2473104,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4749367,
				sizeY = 0.2586836,
				image = "gf#tz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db3",
				posX = 0.2359928,
				posY = 0.5246218,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4456752,
				sizeY = 1.256463,
				image = "gf#dg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wpd1",
				varName = "gradeIcon",
				posX = 0.229252,
				posY = 0.5412076,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2138341,
				sizeY = 0.5727994,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb1",
					varName = "icon",
					posX = 0.502196,
					posY = 0.522153,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8254439,
					sizeY = 0.8390281,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "new1",
					varName = "newImg",
					posX = 0.3527352,
					posY = 0.9783797,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 1.063158,
					sizeY = 0.4301075,
					image = "kc#new",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "countLabel",
					posX = 0.5542209,
					posY = 0.2044171,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7295569,
					sizeY = 0.5273215,
					text = "x666",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sm",
				posX = 0.7209381,
				posY = 0.8441534,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.470008,
				sizeY = 0.2125083,
				image = "d#tyd",
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "djm",
					varName = "nameLabel",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9942945,
					sizeY = 1,
					text = "道具名字六个",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "djm2",
					varName = "ownCounts",
					posX = 0.5,
					posY = -0.3999218,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.121898,
					sizeY = 1,
					text = "当前拥有:19/40",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yb2",
				posX = 0.6848853,
				posY = 0.4522456,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1012898,
				sizeY = 0.277161,
				image = "tb#tongqian",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "jg",
					varName = "priceLabel",
					posX = 2.08903,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.356179,
					sizeY = 0.849956,
					text = "90",
					color = "FF966856",
					fontSize = 22,
					fontOutlineColor = "FF27221D",
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gmn",
				varName = "btn",
				posX = 0.7209381,
				posY = 0.1917545,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2926151,
				sizeY = 0.3141158,
				image = "chu1#an4",
				imageNormal = "chu1#an4",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "gmz",
					posX = 0.5,
					posY = 0.5588235,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7898721,
					sizeY = 0.8527673,
					text = "购 买",
					fontSize = 24,
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
				etype = "Image",
				name = "ys",
				varName = "saleOut",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.00099,
				sizeY = 0.9891071,
				image = "b#bp",
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
					name = "ys2",
					posX = 0.235262,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3710287,
					sizeY = 0.6102424,
					image = "sc#ysw",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "dj",
				posX = 0.2511483,
				posY = 0.5554629,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3199479,
				sizeY = 0.6902266,
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
