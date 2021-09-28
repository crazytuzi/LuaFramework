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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5101563,
			sizeY = 0.6125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "cjsl",
				varName = "img",
				posX = 0.5091885,
				posY = 0.4928946,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.005961,
				sizeY = 1.018591,
				image = "dadianying#dadianying",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "buyBtn",
				posX = 0.3448045,
				posY = 0.1855675,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5794721,
				sizeY = 0.2589479,
				image = "czan#hd2",
				imageNormal = "czan#hd2",
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
