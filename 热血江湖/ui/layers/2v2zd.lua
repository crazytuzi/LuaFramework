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
			etype = "Grid",
			name = "xsysjm",
			varName = "roleInfoUI",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tp",
				posX = 0.8876246,
				posY = 0.8560371,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1981162,
				sizeY = 0.2589521,
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
					name = "dt1",
					posX = 0.1881698,
					posY = 0.4141251,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.311528,
					sizeY = 0.8259785,
					image = "zd2#f",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt2",
					posX = 0.4921132,
					posY = 0.4141251,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2760375,
					sizeY = 0.8259785,
					image = "zd2#p",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "dt3",
					posX = 0.819717,
					posY = 0.4141251,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2760375,
					sizeY = 0.8259785,
					image = "zd2#s",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.832537,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.108093,
					sizeY = 0.4183528,
					image = "zd2#top",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "cc",
					varName = "timesLabel",
					posX = 0.5,
					posY = 0.8058739,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6959618,
					sizeY = 0.5393208,
					text = "第一场",
					color = "FFFFFBBE",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF790000",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "cc3",
					varName = "winLabel",
					posX = 0.1800509,
					posY = 0.2432462,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2043348,
					sizeY = 0.5507379,
					text = "0",
					color = "FFFFF114",
					fontSize = 26,
					fontOutlineEnable = true,
					fontOutlineColor = "FFFF5A00",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "cc5",
					varName = "drawLabel",
					posX = 0.5039434,
					posY = 0.2539732,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2043348,
					sizeY = 0.5507379,
					text = "0",
					fontSize = 26,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "cc7",
					varName = "loseLabel",
					posX = 0.829623,
					posY = 0.2539732,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2043348,
					sizeY = 0.5507379,
					text = "0",
					fontSize = 26,
					fontOutlineEnable = true,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sz1",
					posX = 0.1805846,
					posY = 0.564362,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1222452,
					sizeY = 0.3003558,
					image = "zd2#sheng",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sz2",
					posX = 0.5039434,
					posY = 0.564362,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1261886,
					sizeY = 0.3218098,
					image = "zd2#ping",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sz3",
					posX = 0.8312456,
					posY = 0.564362,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1064716,
					sizeY = 0.3432638,
					image = "zd2#fu",
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
