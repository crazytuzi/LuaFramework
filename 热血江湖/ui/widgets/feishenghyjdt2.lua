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
			name = "qm9",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.24375,
			sizeY = 0.04983371,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dwt9",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 1,
				image = "d#bt",
				alpha = 0.2,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "js9",
				varName = "value",
				posX = 0.7047665,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5312262,
				sizeY = 1.532876,
				text = "66666",
				color = "FFEDE160",
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an5",
				varName = "selectBtn",
				posX = 0.1045238,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.110491,
				sizeY = 1,
				image = "zq#ws",
				imageNormal = "zq#ws",
				imagePressed = "zq#ys",
				imageDisable = "zq#ws",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc10",
				varName = "name",
				posX = 0.3364352,
				posY = 0.5000006,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.344984,
				sizeY = 1.532876,
				text = "气血：",
				color = "FFDEA484",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ss",
				varName = "arrow",
				posX = 0.8488881,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.09615385,
				sizeY = 0.836114,
				image = "chu1#ss",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "max",
				varName = "maxImg",
				posX = 0.845683,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2179487,
				sizeY = 0.7525027,
				image = "gf#max",
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
