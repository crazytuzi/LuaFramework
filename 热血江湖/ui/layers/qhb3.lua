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
			name = "jd1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "hx",
				posX = 0.5,
				posY = 0.9194446,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.00234375,
				sizeY = 0.2527778,
				image = "qhb#xian",
				alpha = 0,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.487505,
				posY = 0.7136427,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1311481,
				sizeY = 0.2291667,
				image = "qhb#db3",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
				alpha = 0,
				alphaCascade = true,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "bt",
					varName = "okBtn",
					posX = 0.6105287,
					posY = 0.1501019,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.5659156,
					sizeY = 0.2363636,
					image = "qhb#an",
					alphaCascade = true,
					imageNormal = "qhb#an",
					disablePressScale = true,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "xnz",
						posX = 0.4473685,
						posY = 0.4487177,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8463675,
						sizeY = 0.8449824,
						text = "确 定",
						fontSize = 18,
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
					name = "zt",
					varName = "image",
					posX = 0.5682566,
					posY = 0.3957688,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1025641,
					sizeY = 0.3217392,
					image = "qhb#qgl",
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
	hx = {
		hx = {
			move = {{0, {634, 860, 0}}, {200, {634, 662.0001, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	db = {
		db = {
			move = {{0, {624.0064, 860, 0}}, {200, {624.0064, 598, 0}}, {300, {624.0064, 600, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	hx2 = {
		hx = {
			move = {{0, {640,662.0001,0}}, {200, {640, 860, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	db2 = {
		db = {
			move = {{0, {624.0064,513.8228,0}}, {200, {624.0064, 860, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	c_dakai = {
		{0,"hx", 1, 0},
		{0,"db", 1, 0},
	},
	c_guanbi = {
		{0,"hx2", 1, 0},
		{0,"db2", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
