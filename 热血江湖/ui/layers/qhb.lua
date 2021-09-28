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
				posX = 0.4945316,
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
				posX = 0.4867235,
				posY = 0.8025323,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.105239,
				sizeY = 0.1666667,
				image = "qhb#db1",
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
					name = "dja",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					alphaCascade = true,
					disablePressScale = true,
					propagateToChildren = true,
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "an",
						varName = "grabBtn",
						posX = 0.5827431,
						posY = 0.4021049,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.3799128,
						sizeY = 0.4117648,
						image = "qhb#qiang",
						alphaCascade = true,
						imageNormal = "qhb#qiang",
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
				etype = "Label",
				name = "wb",
				varName = "desc",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6,
				sizeY = 0.25,
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
	hx = {
		hx = {
			move = {{0, {634, 850, 0}}, {200, {634, 662.0001, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	db = {
		db = {
			move = {{0, {623.0061, 860, 0}}, {200, {623.0061, 598, 0}}, {300, {623.0061, 600, 0}}, },
			alpha = {{0, {1}}, },
		},
	},
	an = {
		an = {
			scale = {{0, {1,1,1}}, {150, {1.2, 1.2, 1}}, {300, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"hx", 1, 0},
		{0,"db", 1, 0},
		{0,"an", -1, 200},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
