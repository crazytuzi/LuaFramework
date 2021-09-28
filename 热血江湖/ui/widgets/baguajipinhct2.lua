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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.207784,
			sizeY = 0.05,
			fontSize = 18,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "des",
				posX = 0.5904701,
				posY = 0.4999992,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8265795,
				sizeY = 1.304242,
				text = "文本",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "tzz",
				varName = "num",
				posX = 0.3232712,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 1.527778,
				text = "3件：",
				color = "FF966856",
				fontSize = 18,
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
