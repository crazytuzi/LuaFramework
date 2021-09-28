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
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3328125,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt4",
				varName = "propertyBg2",
				posX = 0.5,
				posY = 0.02222222,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.96,
				sizeY = 0.04444445,
				image = "d2#fgx",
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "propertyName",
				posX = 0.3636168,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.46567,
				sizeY = 0.7982667,
				text = "我要写六个字：",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "propertyValue",
				posX = 0.7979638,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5333695,
				sizeY = 0.8510796,
				text = "123123",
				color = "FFF1E9D7",
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "propertyIcon",
				posX = 0.07715681,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08215962,
				sizeY = 0.8749999,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				posX = 0.5002725,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.03286385,
				sizeY = 0.375,
				image = "chu1#jt",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z3",
				varName = "differValue",
				posX = 0.9370801,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3482923,
				sizeY = 0.7737387,
				text = "+555",
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
	ss = {
		z3 = {
			alpha = {{0, {0.2}}, {700, {1}}, {1400, {0.2}}, },
		},
	},
	c_dakai = {
		{0,"ss", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
