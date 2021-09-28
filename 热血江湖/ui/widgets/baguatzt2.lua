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
			sizeY = 0.1111111,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.95,
				sizeY = 0.95,
				image = "b#ff1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
				imageNormal = "b#ff1",
				imagePressed = "b#ff2",
				imageDisable = "b#ff1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "sxz",
				varName = "daw",
				posX = 0.6325184,
				posY = 0.4722217,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6722181,
				sizeY = 1.388889,
				text = "套装名字",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djt",
				varName = "rankIcon",
				posX = 0.1829186,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2349025,
				sizeY = 0.7487518,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "icon",
					posX = 0.5082373,
					posY = 0.520843,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8498219,
					sizeY = 0.8417206,
				},
			},
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
