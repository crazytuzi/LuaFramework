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
			name = "tj1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.215625,
			sizeY = 0.1575945,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dw",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8913044,
				sizeY = 0.95,
				image = "yqs#lbt",
				scale9 = true,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn1",
				varName = "getBtn",
				posX = 0.6302176,
				posY = 0.3592986,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4456522,
				sizeY = 0.5111572,
				image = "chu1#an3",
				imageNormal = "chu1#an3",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "tjz3",
					varName = "getLabel",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9054239,
					sizeY = 1.144804,
					text = "领 取",
					fontOutlineEnable = true,
					fontOutlineColor = "FF347468",
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
				name = "tjz1",
				varName = "shakeDesc",
				posX = 0.7876656,
				posY = 0.737738,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6978936,
				sizeY = 0.3876166,
				text = "摇一摇5次",
				color = "FF6B25DF",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "bg",
				posX = 0.2612645,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.307971,
				sizeY = 0.7491096,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.5013424,
					posY = 0.5210938,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8363664,
					sizeY = 0.8238217,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.2132133,
					posY = 0.2238367,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3191489,
					sizeY = 0.3191489,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "count",
					posX = 0.4428451,
					posY = 0.1865381,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9531804,
					sizeY = 0.7919649,
					text = "x10",
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
				etype = "Button",
				name = "btn2",
				varName = "btn",
				posX = 0.2502946,
				posY = 0.5078864,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3180887,
				sizeY = 0.8816754,
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
