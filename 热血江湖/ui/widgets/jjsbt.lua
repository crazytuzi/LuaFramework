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
			sizeX = 0.09375,
			sizeY = 0.1872943,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "bt",
				varName = "img",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6666667,
				sizeY = 0.5932434,
				image = "tb#wg",
				imageNormal = "tb#wg",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "name",
				varName = "name",
				posX = 0.4999973,
				posY = 0.02574928,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.031642,
				sizeY = 0.2804689,
				text = "name",
				hTextAlign = 1,
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
