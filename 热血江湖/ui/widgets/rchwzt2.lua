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
			sizeX = 0.215625,
			sizeY = 0.07361111,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7789855,
				sizeY = 1.018868,
				image = "phb#phd1",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				imageNormal = "phb#phd1",
				imagePressed = "phb#phd2",
				imageDisable = "phb#phd1",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "nameLabel",
				posX = 0.5,
				posY = 0.5188679,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8349082,
				sizeY = 0.7982667,
				text = "具体什么榜",
				color = "FF914A15",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xin",
				varName = "redPoint",
				posX = 0.818339,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1268116,
				sizeY = 0.9433962,
				image = "yj#new",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "ywc",
				varName = "finished",
				posX = 0.6193677,
				posY = 0.518842,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.3038352,
				sizeY = 0.9434454,
				image = "huigui#ywc",
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
