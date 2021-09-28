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
			name = "jm",
			varName = "root",
			posX = 0.3943695,
			posY = 0.5027717,
			anchorX = 0,
			anchorY = 0,
			sizeX = 0.2109375,
			sizeY = 0.2717754,
			layoutType = 1,
			layoutTypeW = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "bg",
				posX = 0.4988381,
				posY = 0.001505383,
				anchorX = 0.5,
				anchorY = 0,
				sizeX = 0.9889694,
				sizeY = 1.003598,
				image = "b#bp",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "lb",
				varName = "scroll",
				posX = 0.5005066,
				posY = 0.499667,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9923056,
				sizeY = 0.9496477,
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
