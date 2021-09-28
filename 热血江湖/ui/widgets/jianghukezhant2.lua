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
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2632813,
			sizeY = 0.2152778,
			image = "b#tzt",
			scale9 = true,
			scale9Left = 0.4,
			scale9Right = 0.5,
			scale9Top = 0.25,
			scale9Bottom = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cdg3",
				posX = 0.539492,
				posY = 0.45,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5112314,
				sizeY = 0.191358,
				image = "d#cdd2",
				rotation = 90,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.2674936,
				posY = 0.2473104,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.535503,
				sizeY = 0.2530864,
				image = "gf#tz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db2",
				posX = 0.2675054,
				posY = 0.5246218,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5076788,
				sizeY = 1.091167,
				image = "gf#dg",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "wpd1",
				varName = "gradeIcon",
				posX = 0.2607646,
				posY = 0.5412076,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.281899,
				sizeY = 0.6193548,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tb1",
					varName = "icon",
					posX = 0.5,
					posY = 0.5416668,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
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
					sizeY = 0.4166667,
					image = "kc#new",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "countLabel",
					posX = 0.5542209,
					posY = 0.2259225,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7295569,
					sizeY = 0.5273215,
					text = "x666",
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
				posX = 0.7411962,
				posY = 0.7464725,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.470008,
				sizeY = 0.228395,
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
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yb",
				posX = 0.6891636,
				posY = 0.487672,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1430499,
				sizeY = 0.2984621,
				image = "tb#tongqian",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "jg",
					varName = "priceLabel",
					posX = 1.941925,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.832566,
					sizeY = 0.7884529,
					text = "90",
					color = "FF634624",
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
				posX = 0.7481151,
				posY = 0.1980384,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3857566,
				sizeY = 0.3290322,
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
					posY = 0.5,
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
				posX = 0.2600381,
				posY = 0.5739604,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4896141,
				sizeY = 0.632258,
				image = "sc#ysw",
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
