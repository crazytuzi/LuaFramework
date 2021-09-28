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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1762729,
			sizeY = 0.3868645,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a",
				varName = "selectBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9927788,
				sizeY = 0.9872822,
				image = "xunyang#lichi",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd",
				varName = "red_point",
				posX = 0.9217612,
				posY = 0.9362264,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1196653,
				sizeY = 0.1005233,
				image = "zdte#hd",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "des",
				posX = 0.4999999,
				posY = 0.09030055,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.070732,
				sizeY = 0.4198623,
				text = "远航等级",
				color = "FFFBF9F7",
				fontOutlineEnable = true,
				fontOutlineColor = "FF9C4F17",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xhd2",
				varName = "max",
				posX = 0.4814192,
				posY = 0.2204187,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3013793,
				sizeY = 0.09693316,
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
