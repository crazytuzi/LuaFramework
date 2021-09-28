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
			name = "xjst",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3148437,
			sizeY = 0.1666667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "saz",
				posX = 0.4181138,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8411912,
				sizeY = 0.9999998,
				image = "dl#d4",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "saz2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "dl#d4",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				posX = 0.1556526,
				posY = 0.5092989,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2655087,
				sizeY = 0.9416665,
				image = "dl#njd",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx1",
				posX = 0.1522924,
				posY = 0.4166667,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3697271,
				sizeY = 1.066666,
				image = "dl#xj",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btnCreate",
				posX = 0.5000026,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.95,
				sizeY = 0.96,
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "guang",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.8999999,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "g2",
					posX = 0.1556495,
					posY = 0.5277257,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3567184,
					sizeY = 1.331087,
					image = "uieffect/34d5bb3a.png",
					alpha = 0,
					flippedY = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "g3",
					posX = 0.1606083,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.361682,
					sizeY = 1.349611,
					image = "uieffect/guangyun0144.png",
					alpha = 0,
					blendFunc = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "g4",
					posX = 0.1556495,
					posY = 0.5277257,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.376555,
					sizeY = 1.405107,
					image = "uieffect/34d5bb3a.png",
					alpha = 0,
					flippedY = true,
					blendFunc = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jsaz",
				posX = 0.5272954,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4019852,
				sizeY = 0.5666665,
				image = "dl#xinjianjuese",
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
	g = {
		g3 = {
			rotate = {{0, {0}}, {1000, {180}}, {1500, {270}}, {2000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	g2 = {
		g2 = {
			rotate = {{0, {0}}, {4000, {180}}, {6000, {270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	g4 = {
		g4 = {
			rotate = {{0, {0}}, {4000, {-180}}, {6000, {-270}}, {8000, {0}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"g", -1, 0},
		{0,"g2", -1, 0},
		{0,"g4", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
