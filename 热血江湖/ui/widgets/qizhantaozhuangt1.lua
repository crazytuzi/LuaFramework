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
			sizeX = 0.240625,
			sizeY = 0.08395047,
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
				sizeX = 0.98,
				sizeY = 0.92,
				image = "zqqz2#h2",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.5,
				imageNormal = "zqqz2#h2",
				imagePressed = "zqqz2#h1",
				imageDisable = "zqqz2#h2",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "nameLabel",
				posX = 0.5998998,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5990446,
				sizeY = 0.7982667,
				text = "套装名字",
				color = "FF914A15",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp",
				varName = "state",
				posX = 0.1558558,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.237013,
				sizeY = 0.4632361,
				image = "xingpan#yjh",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "yq",
				varName = "colorPoint",
				posX = 0.9096188,
				posY = 0.4219271,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1136364,
				sizeY = 0.562501,
				image = "zqqz2#v1",
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
