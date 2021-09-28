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
			name = "jn1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0828125,
			sizeY = 0.1222222,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jnk1",
				varName = "borderIcon",
				posX = 0.8950869,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1603774,
				sizeY = 0.409091,
				image = "jingmai#xz",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jnt1",
				varName = "skill_icon",
				posX = 0.5032886,
				posY = 0.49,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7075472,
				sizeY = 0.8522729,
				image = "jingmai#ren1",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "jna1",
				varName = "skill_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "ch/kong",
				imageNormal = "ch/kong",
				imagePressed = "ji#xz",
				imageDisable = "ch/kong",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd3",
				varName = "redPoint",
				posX = 0.7473712,
				posY = 0.8116176,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.254717,
				sizeY = 0.3181819,
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
