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
			sizeX = 0.07421875,
			sizeY = 0.1319444,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "jl2",
				varName = "stoneBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8897675,
				sizeY = 0.815313,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jl1",
				varName = "stoneBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9894737,
				sizeY = 0.989474,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jiangli",
					varName = "stoneIcon",
					posX = 0.4946854,
					posY = 0.5108859,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7965636,
					sizeY = 0.7864825,
				},
			},
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
