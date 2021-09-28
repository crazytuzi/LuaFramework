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
			etype = "Button",
			name = "an",
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
			etype = "Grid",
			name = "jd2",
			varName = "upBar2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			visible = false,
			sizeX = 1,
			sizeY = 1,
			layoutType = 8,
			layoutTypeW = 8,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an2",
				varName = "breakBtn2",
				posX = 0.9180759,
				posY = 0.9353727,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1289063,
				sizeY = 0.06805556,
				image = "l#tgdh",
				imageNormal = "l#tgdh",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "jd1",
			varName = "upBar1",
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
				name = "zmdt",
				posX = 0.5,
				posY = 0.9347217,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.25,
				sizeY = 0.1359477,
				image = "l#bian",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "breakBtn1",
				posX = 0.9180759,
				posY = 0.9353727,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1289063,
				sizeY = 0.06805556,
				image = "l#tgdh",
				imageNormal = "l#tgdh",
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
