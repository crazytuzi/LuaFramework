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
			sizeX = 0.3229063,
			sizeY = 0.1111111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tp",
				varName = "typeImg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8105099,
				sizeY = 0.7500001,
				image = "zhanbu#yi",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb10",
				varName = "name",
				posX = 0.5586947,
				posY = 0.5000004,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6149781,
				sizeY = 1.266268,
				text = "打怪",
				color = "FF25693C",
				fontSize = 22,
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
