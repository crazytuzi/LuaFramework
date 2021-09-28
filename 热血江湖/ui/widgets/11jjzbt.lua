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
			name = "jjpht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.740625,
			sizeY = 0.2041667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tdt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9894515,
				sizeY = 0.972789,
				image = "b#lbt",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.7,
				scale9Top = 0.5,
				scale9Bottom = 0.2,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "shb",
				varName = "markImg",
				posX = 0.1148302,
				posY = 0.5884359,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1903493,
				sizeY = 0.8163264,
				image = "jjc#sheng",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ttxk",
				varName = "iconType",
				posX = 0.2829686,
				posY = 0.4455784,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1550633,
				sizeY = 0.802721,
				image = "zdtx#txd.png",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt",
					varName = "icon",
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
					name = "djd",
					posX = 0.8223289,
					posY = 0.2700532,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2857143,
					sizeY = 0.3644068,
					image = "zdte#djd2",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "dj",
						varName = "level",
						posX = 0.5,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.255264,
						sizeY = 1.07061,
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
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.4717949,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2308304,
				sizeY = 0.5201096,
				text = "你是一个大草包",
				color = "FF966856",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "lineup",
				posX = 0.8586796,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1835443,
				sizeY = 0.4489796,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "az1",
					varName = "word",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7809228,
					sizeY = 0.7905752,
					text = "胜利阵容",
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
				etype = "Label",
				name = "ms",
				varName = "timeLabel",
				posX = 0.6687826,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2028352,
				sizeY = 0.4297656,
				text = "100分钟前",
				color = "FF966856",
				fontSize = 22,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
