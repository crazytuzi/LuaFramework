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
			name = "t",
			varName = "root1",
			posX = 0.5,
			posY = 0.8,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5125,
			sizeY = 0.08611111,
			image = "d#tst",
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "z1",
				varName = "tipWord1",
				posX = 0.4999999,
				posY = 0.5345405,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.6,
				sizeY = 1,
				text = "提示文字提示文字提示文字",
				color = "FFFFF554",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
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
			name = "t2",
			varName = "root2",
			posX = 0.5,
			posY = 0.8,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5125,
			sizeY = 0.08611111,
			image = "d#tst",
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "z2",
				varName = "tipWord2",
				posX = 0.4999999,
				posY = 0.5345404,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.6,
				sizeY = 1,
				text = "提示文字提示文字提示文字",
				color = "FFFFF554",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
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
			name = "t3",
			varName = "root3",
			posX = 0.5,
			posY = 0.8,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5125,
			sizeY = 0.08611111,
			image = "d#tst",
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "z3",
				varName = "tipWord3",
				posX = 0.4999999,
				posY = 0.5103818,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.6,
				sizeY = 1,
				text = "提示文字提示文字提示文字",
				color = "FFFFF554",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
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
			name = "t4",
			varName = "root4",
			posX = 0.5,
			posY = 0.8,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5125,
			sizeY = 0.08611111,
			image = "d#tst",
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "z4",
				varName = "tipWord4",
				posX = 0.4999999,
				posY = 0.5184351,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.6,
				sizeY = 1,
				text = "提示文字提示文字提示文字",
				color = "FFFFF554",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				fontOutlineSize = 2,
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
	xs1 = {
		t = {
			move = {{0, {640,494.8233,0}}, {200, {640,494.8233,0}}, {1000, {640, 650, 0}}, },
			alpha = {{0, {0}}, {200, {0.7}}, {1000, {0}}, },
		},
		z1 = {
			alpha = {{0, {0}}, {200, {1}}, {1000, {0}}, },
		},
	},
	xs2 = {
		t2 = {
			move = {{0, {640,494.8233,0}}, {200, {640,494.8233,0}}, {1000, {640, 650, 0}}, },
			alpha = {{0, {0}}, {200, {0.7}}, {1000, {0}}, },
		},
		z2 = {
			alpha = {{0, {0}}, {200, {1}}, {1000, {0}}, },
		},
	},
	xs3 = {
		t3 = {
			move = {{0, {640,494.8233,0}}, {200, {640,494.8233,0}}, {1000, {640, 650, 0}}, },
			alpha = {{0, {0}}, {200, {0.7}}, {1000, {0}}, },
		},
		z3 = {
			alpha = {{0, {0}}, {200, {1}}, {1000, {0}}, },
		},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
