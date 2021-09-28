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
				varName = "close_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "xxysjm",
			posX = 0.5,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "zza",
				varName = "closebtn",
				posX = 0.4954639,
				posY = 0.203148,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6236858,
				sizeY = 0.3881041,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt5",
				posX = 0.5,
				posY = 0.2,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.25,
				sizeY = 0.4,
				image = "l#db",
				scale9 = true,
				scale9Left = 0.35,
				scale9Right = 0.6,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				posX = 0.5,
				posY = 0.2,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.4,
				scale9 = true,
				scale9Left = 0.35,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "sl",
					varName = "desText",
					posX = 0.514819,
					posY = 0.74717,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4243028,
					sizeY = 0.3791934,
					text = "改变性别描述",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.3210512,
				posY = 0.4325384,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2304688,
				sizeY = 0.06547619,
				image = "l#mzd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "top",
					varName = "npcName",
					posX = 0.5305085,
					posY = 0.504329,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8244094,
					sizeY = 1.118634,
					text = "NPC名字",
					color = "FFFFFF00",
					fontSize = 26,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				varName = "npcmodule",
				posX = 0.1189844,
				posY = -0.2512159,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2238505,
				sizeY = 1.275682,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "exit_Btn",
				posX = 0.3735908,
				posY = 0.1394252,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1520619,
				sizeY = 0.1587302,
				image = "ty#fhan",
				alphaCascade = true,
				imageNormal = "ty#fhan",
				propagateToChildren = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "gl1",
					varName = "name",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9317102,
					sizeY = 0.9444929,
					text = "不感兴趣",
					color = "FFD8FFF3",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF055444",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an2",
				varName = "ok_Btn",
				posX = 0.6127442,
				posY = 0.1394252,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1520619,
				sizeY = 0.1587302,
				image = "ty#fhan",
				alphaCascade = true,
				imageNormal = "ty#fhan",
				propagateToChildren = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "gl2",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9317102,
					sizeY = 0.9444929,
					text = "改变性别",
					color = "FFD8FFF3",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF055444",
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
				name = "yb",
				varName = "itemIcon",
				posX = 0.7191564,
				posY = 0.1394826,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.04296874,
				sizeY = 0.109127,
				image = "tb#yuanbao",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "ssl",
					varName = "itemCount",
					posX = 2.393965,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.56591,
					sizeY = 0.9267452,
					text = "x555",
					fontSize = 22,
					vTextAlign = 1,
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
