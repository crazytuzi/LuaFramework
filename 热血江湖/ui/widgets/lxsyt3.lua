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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.065625,
			sizeY = 0.1166667,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "headBtn",
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
				name = "djk",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx",
					varName = "headIcon",
					posX = 0.5104498,
					posY = 0.5208984,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7872711,
					sizeY = 0.7549227,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cz",
				varName = "fightIcon",
				posX = 0.381035,
				posY = 0.749667,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.713097,
				sizeY = 0.4445279,
				image = "zq#cz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "cz2",
				varName = "trip",
				posX = 0.381035,
				posY = 0.749667,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.713097,
				sizeY = 0.4445279,
				image = "zq#lxz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "effect",
				posX = 0.5,
				posY = 0.5238096,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.093419,
				sizeY = 1.093419,
				image = "djk#zbxz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "red",
				posX = 0.8683987,
				posY = 0.8684157,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.3214286,
				sizeY = 0.3333333,
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
	gy = {
	},
	gy3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
