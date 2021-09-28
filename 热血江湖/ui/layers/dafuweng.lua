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
			name = "jjd",
			varName = "parent",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				posX = 0.5007812,
				posY = 0.4791665,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9652778,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "db2",
					posX = 0.5,
					posY = 0.5230213,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.035971,
					image = "dfwbj3#dfwbj3",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "db",
					posX = 0.8502063,
					posY = 0.2250536,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.290625,
					sizeY = 0.4273381,
					image = "dfwdj3#db",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gb",
					varName = "close",
					posX = 0.9284022,
					posY = 0.864239,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.0515625,
					sizeY = 0.1661808,
					image = "dfwdj#gb",
					imageNormal = "dfwdj#gb",
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
			},
			{
				prop = {
					etype = "Grid",
					name = "jd",
					posX = 0.5,
					posY = 0.5204086,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1.049563,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "sz",
						varName = "diceBtn",
						posX = 0.8858423,
						posY = 0.2725822,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.1078125,
						sizeY = 0.1428571,
						image = "dfwdj#go",
						imageNormal = "dfwdj#go",
						disablePressScale = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "cs",
						varName = "timesLabel",
						posX = 0.8874561,
						posY = 0.05097683,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.2616389,
						sizeY = 0.09225359,
						text = "剩余次数：10",
						color = "FF835B25",
						fontSize = 22,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				{
					prop = {
						etype = "Button",
						name = "shijian",
						varName = "eventBtn",
						posX = 0.8885766,
						posY = 0.2692758,
						anchorX = 0.5,
						anchorY = 0.5,
						visible = false,
						sizeX = 0.1182378,
						sizeY = 0.1347994,
						propagateToChildren = true,
					},
					children = {
					{
						prop = {
							etype = "Button",
							name = "xbt",
							posX = 0.5,
							posY = 0.6854612,
							anchorX = 0.5,
							anchorY = 0.5,
							sizeX = 0.3501947,
							sizeY = 1.195191,
							image = "dfwdj#th1",
							imageNormal = "dfwdj#th1",
							disablePressScale = true,
							disableClick = true,
						},
					},
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bz",
					varName = "helpBtn",
					posX = 0.8658928,
					posY = 0.8855842,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.040625,
					sizeY = 0.1326531,
					image = "dfwdj#wh",
					imageNormal = "dfwdj#wh",
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
				posY = 0.8751824,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3257813,
				sizeY = 0.1402778,
				image = "dfwdj3#top",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx1",
				varName = "model",
				posX = 0.1773428,
				posY = 0.1912685,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1055754,
				sizeY = 0.2699692,
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx2",
				varName = "diceModel",
				posX = 0.5000148,
				posY = 0.4972278,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07344148,
				sizeY = 0.1862053,
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx3",
				varName = "diceModel3",
				posX = 0.65,
				posY = 0.4972278,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07344148,
				sizeY = 0.1862053,
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx4",
				varName = "diceModel2",
				posX = 0.35,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07344148,
				sizeY = 0.1862053,
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
