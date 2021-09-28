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
			etype = "Grid",
			name = "yg",
			posX = 0,
			posY = 0,
			anchorX = 0,
			anchorY = 0,
			sizeX = 0.5,
			sizeY = 0.5,
			layoutType = 1,
			layoutTypeW = 1,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dt",
				varName = "direct",
				posX = 0.300326,
				posY = 0.5778189,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3354689,
				sizeY = 0.5963891,
				disablePressScale = true,
				propagateToChildren = true,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "bt",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7918022,
					sizeY = 0.7918022,
					image = "zdte#ygd4",
					imageNormal = "zdte#ygd4",
					imagePressed = "zdte#ygd4",
					imageDisable = "zdte#ygd4",
					disablePressScale = true,
					disableClick = true,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "control",
				posX = 0.300326,
				posY = 0.5778189,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1390625,
				sizeY = 0.2472222,
				image = "zdte#yg4.png",
				imageNormal = "zdte#yg4.png",
				imagePressed = "zdte#yg2.png",
				imageDisable = "zdte#yg4.png",
				disablePressScale = true,
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
