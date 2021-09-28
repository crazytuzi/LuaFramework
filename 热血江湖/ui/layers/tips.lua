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
			etype = "Image",
			name = "t",
			varName = "img",
			posX = 0.5,
			posY = 0.8,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5125,
			sizeY = 0.08611111,
			image = "d#tst",
		},
	},
	{
		prop = {
			etype = "Label",
			name = "z1",
			varName = "tipWord",
			posX = 0.5,
			posY = 0.8027778,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.7526683,
			sizeY = 0.07012361,
			text = "dwads",
			color = "FFFFF554",
			fontSize = 24,
			fontOutlineColor = "FF102E21",
			hTextAlign = 1,
			vTextAlign = 1,
			layoutType = 5,
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
