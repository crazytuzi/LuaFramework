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
			name = "k2",
			varName = "node",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1992188,
			sizeY = 0.05,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "sxz",
				varName = "daw",
				posX = 0.5092169,
				posY = 0.4722222,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9815662,
				sizeY = 1.388889,
				color = "FF966856",
				fontSize = 18,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "sxz2",
				varName = "des2",
				posX = 0.6154244,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8497186,
				sizeY = 1.388889,
				color = "FF966856",
				fontSize = 18,
				fontOutlineColor = "FF102E21",
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
