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
			name = "pz12",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1612664,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "sz12",
				varName = "groupBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				alpha = 0.5,
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "pzz12",
				varName = "groupName",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				text = "经验丹",
				color = "FFF1DDC1",
				fontSize = 24,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian11",
				posX = 0.5,
				posY = 0.06666663,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9499999,
				sizeY = 0.04999997,
				image = "b#xian",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hd",
				varName = "red",
				posX = 0.9304049,
				posY = 0.7195264,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.1308006,
				sizeY = 0.5599999,
				image = "zdte#hd",
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
