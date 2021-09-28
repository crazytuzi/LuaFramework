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
			name = "d",
			varName = "suitRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4453125,
			sizeY = 0.0625,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dd",
				posX = 0.3416207,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4877193,
				sizeY = 0.7111111,
				image = "cl2#dw2",
				scale9Left = 0.41,
				scale9Right = 0.37,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "mz",
					varName = "suitName",
					posX = 0.5550661,
					posY = 0.5625,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8898679,
					sizeY = 1.458827,
					text = "帮派等级达到5级可用",
					color = "FF43261D",
					fontSize = 22,
					vTextAlign = 1,
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
