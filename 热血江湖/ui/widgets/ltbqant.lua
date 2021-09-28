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
			sizeX = 0.07299256,
			sizeY = 0.1,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "djan",
				varName = "btn",
				posX = 0.51,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.048908,
				sizeY = 1,
				image = "bqb#bqa1",
				imageNormal = "bqb#bqa1",
				imagePressed = "bqb#baq2",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bqt",
				varName = "emoji",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.113127,
				sizeY = 1,
				image = "bqb#moren",
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
