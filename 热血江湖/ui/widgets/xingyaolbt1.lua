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
			sizeX = 0.203125,
			sizeY = 0.07361111,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9,
				sizeY = 1.037736,
				image = "phb#phd1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "phb#phd1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "nameLabel",
				posX = 0.6479051,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5160208,
				sizeY = 0.7982667,
				text = "具体星耀",
				color = "FF914A15",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp",
				varName = "state",
				posX = 0.215032,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2807692,
				sizeY = 0.5283019,
				image = "xingpan#zbz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yq",
				varName = "colorPoint",
				posX = 0.8538491,
				posY = 0.5377358,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1961538,
				sizeY = 0.9811321,
				image = "xingpan#yqlan",
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
