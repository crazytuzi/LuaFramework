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
			name = "cheng",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1015625,
			sizeY = 0.2319444,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "City",
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
				name = "chengt",
				varName = "CityImg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9846154,
				sizeY = 0.9820361,
				image = "chengchit#1",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc",
				varName = "CityName",
				posX = 0.4923185,
				posY = 0.1692002,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8764269,
				sizeY = 0.4146064,
				text = "天水城",
				color = "FF5A268F",
				fontSize = 22,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc2",
				varName = "SectName",
				posX = 0.5,
				posY = 0.8626974,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.659282,
				sizeY = 0.4146064,
				text = "天水城天水城天",
				color = "FFFFFF00",
				fontSize = 18,
				hTextAlign = 1,
				vTextAlign = 1,
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
