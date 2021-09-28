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
			lockHV = true,
			sizeX = 0.2000001,
			sizeY = 0.3555556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tp",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9999999,
				image = "duquan#duquan",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t1",
				posX = 0.5,
				posY = 0.9983537,
				anchorX = 0.5,
				anchorY = 0,
				sizeX = 1,
				sizeY = 500,
				image = "zdte2#k",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t2",
				posX = 0.5,
				posY = 5.319854E-05,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 1,
				sizeY = 500,
				image = "zdte2#k",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t3",
				posX = 0.001749282,
				posY = 0.5,
				anchorX = 1,
				anchorY = 0.5,
				sizeX = 500,
				sizeY = 500,
				image = "zdte2#k",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t4",
				posX = 0.9978487,
				posY = 0.5,
				anchorX = 0,
				anchorY = 0.5,
				sizeX = 500,
				sizeY = 500,
				image = "zdte2#k",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
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
