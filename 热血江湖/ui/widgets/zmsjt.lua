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
			name = "zmsjt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2085938,
			sizeY = 0.1680555,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tdt",
				varName = "icon",
				posX = 0.4850188,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9662919,
				sizeY = 1.008265,
				image = "zm#zm_zmdj1.png",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzt",
				varName = "select_icon",
				posX = 0.483164,
				posY = 0.4876235,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9385337,
				sizeY = 0.9983585,
				image = "g#g_xzk.png",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.9900516,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.08779331,
					sizeY = 0.2648977,
					image = "w#w_xzjt.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "bt",
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
				name = "xnd",
				varName = "up_red_point",
				posX = 0.06999027,
				posY = 0.8547932,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.07490635,
				sizeY = 0.1735538,
				image = "zdte#hd",
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
