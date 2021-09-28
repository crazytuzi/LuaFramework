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
			name = "kj",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.203125,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "w1",
				varName = "text",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1.3053,
				text = "12345",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "taskBtn",
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
				name = "tp",
				varName = "image1",
				posX = 0.9205577,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1495702,
				sizeY = 0.9743798,
				image = "sjdt2#csjt",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an2",
				varName = "chuanSongBtn",
				posX = 0.9205577,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1495702,
				sizeY = 0.9743797,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
	c_dakai = {
	},
	c_dakai2 = {
	},
	c_dakai3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
