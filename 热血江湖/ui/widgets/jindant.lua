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
			sizeX = 0.190625,
			sizeY = 0.05555556,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "ms",
				varName = "dsc",
				posX = 0.5236408,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9527186,
				sizeY = 1,
				text = "描述写",
				color = "FF966856",
				fontSize = 18,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xian",
				varName = "icon",
				posX = 0.4999999,
				posY = 0.02625664,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.96,
				sizeY = 0.05251328,
				image = "b#xian",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
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
