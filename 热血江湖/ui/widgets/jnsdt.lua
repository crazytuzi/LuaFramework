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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1570313,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "fy1",
				varName = "pre_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9,
				image = "h#c4",
				imageNormal = "h#c4",
				imagePressed = "h#c2",
				imageDisable = "h#c4",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "fyz1",
				varName = "pre_name",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8730932,
				sizeY = 1.12395,
				text = "当前设",
				color = "FF634624",
				fontSize = 24,
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
