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
				varName = "globel_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
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
				sizeX = 0.678848,
				sizeY = 0.5769884,
				image = "d#diban",
				scale9 = true,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "mzd",
					posX = 0.5,
					posY = 0.7720436,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.579736,
					sizeY = 0.2271752,
					scale9 = true,
					scale9Top = 0.3,
					scale9Bottom = 0.3,
					alpha = 0.5,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb1",
					varName = "mainTitle",
					posX = 0.5029331,
					posY = 0.9248394,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1396454,
					text = "神兵-火龙刀",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF102E21",
					hTextAlign = 1,
					vTextAlign = 1,
					colorTL = "FFFFD060",
					colorTR = "FFFFD060",
					colorBR = "FFF2441C",
					colorBL = "FFF2441C",
					useQuadColor = true,
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "wb2",
					varName = "descText",
					posX = 0.5088058,
					posY = 0.7601265,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.2318699,
					text = "81级开启",
					color = "FF43261D",
					fontSize = 22,
					fontOutlineColor = "FF102E21",
					hTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb5",
					posX = 0.5,
					posY = -0.03397753,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1396454,
					text = "点击任意位置继续",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsx",
					posX = 0.2879553,
					posY = -0.03591882,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1311965,
					sizeY = 0.02166421,
					image = "tong#zsx2",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsx2",
					posX = 0.7156096,
					posY = -0.03591882,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1311965,
					sizeY = 0.02166421,
					image = "tong#zsx2",
				},
			},
			{
				prop = {
					etype = "Sprite3D",
					name = "mx",
					varName = "modelUI",
					posX = 0.5,
					posY = 0.04341057,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.6296704,
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
