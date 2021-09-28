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
			sizeX = 0.2398438,
			sizeY = 0.08472222,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt3",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.95,
				sizeY = 0.8333334,
				image = "d#bt",
				alpha = 0.3,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "name",
				posX = 0.5108217,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7056824,
				sizeY = 0.7982667,
				text = "NPC名字123",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "qz",
				varName = "lamp_icon",
				posX = 0.08957662,
				posY = 0.4922687,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1563518,
				sizeY = 0.7868853,
				image = "sjdt2#csjt",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "selectBtn",
				posX = 0.3608979,
				posY = 0.5086626,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6553105,
				sizeY = 0.8839806,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a2",
				varName = "transBtn",
				posX = 0.8669832,
				posY = 0.5086626,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2600329,
				sizeY = 0.8839806,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx",
				varName = "transImg",
				posX = 0.8539541,
				posY = 0.4922687,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1563518,
				sizeY = 0.7868853,
				image = "sjdt2#csjt",
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
