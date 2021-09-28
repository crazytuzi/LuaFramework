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
				sizeX = 0.7382813,
				sizeY = 0.3152778,
				image = "d#diban",
				scale9 = true,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "smd",
					posX = 0.5,
					posY = 0.398993,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5792592,
					sizeY = 0.6764646,
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
					posY = 0.8504607,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.2723255,
					text = "神兵-火龙刀",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF132F2B",
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
					posY = 0.4011927,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6000001,
					sizeY = 0.6457663,
					text = "1级开启81级开启81级开启\n81级开启81级开启",
					color = "FF43261D",
					fontSize = 22,
					hTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wb5",
					posX = 0.5,
					posY = -0.06370199,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.1990944,
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
					posX = 0.3143867,
					posY = -0.06370194,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1206349,
					sizeY = 0.03964757,
					image = "tong#zsx2",
					flippedX = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zsx2",
					posX = 0.6923535,
					posY = -0.06370194,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1206349,
					sizeY = 0.03964757,
					image = "tong#zsx2",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "gnt",
					varName = "icon",
					posX = 0.5022446,
					posY = 0.2584961,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08465607,
					sizeY = 0.3524229,
					image = "tb#yuanbao",
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
