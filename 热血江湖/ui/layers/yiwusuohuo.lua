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
		closeAfterOpenAni = true,
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
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
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
			sizeX = 0.6,
			sizeY = 0.6,
			alpha = 0,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.4970857,
				posY = 0.4699568,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6869993,
				sizeY = 0.790368,
				scale9 = true,
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5,
					posY = 0.3757053,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.167493,
					sizeY = 0.3187129,
					image = "d#diban",
					scale9 = true,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
					alphaCascade = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "z2",
					varName = "descLabel",
					posX = 0.5313007,
					posY = 0.387128,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8692523,
					sizeY = 0.2490795,
					color = "FF43261D",
					fontOutlineColor = "FF102E21",
					vTextAlign = 1,
					alphaCascade = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dg",
					posX = -0.003280231,
					posY = 0.3717007,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2620351,
					sizeY = 0.4049149,
					image = "hd#dg",
					alphaCascade = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djk",
					posX = -0.003280231,
					posY = 0.3717007,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1800554,
					sizeY = 0.281163,
					image = "djk#ktong",
					alphaCascade = true,
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt",
						varName = "icon",
						posX = 0.5,
						posY = 0.5416668,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
						alphaCascade = true,
					},
				},
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
		dt = {
			alpha = {{0, {0}}, {800, {1}}, {2500, {1}}, },
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
