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
			sizeX = 0.08359375,
			sizeY = 0.25,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "hb1",
				varName = "img",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.009346,
				sizeY = 1.005556,
				image = "xnhb2#hb1",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "btn",
				posX = 0.5,
				posY = 0.4223489,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9392114,
				sizeY = 0.8430539,
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
