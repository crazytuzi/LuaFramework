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
			sizeX = 0.7050915,
			sizeY = 0.6004003,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "shouchong2",
				varName = "img",
				posX = 0.5012617,
				posY = 0.4194325,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9724669,
				sizeY = 0.9755149,
				image = "dadianyings#dadianyings",
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "buyBtn",
					posX = 0.370959,
					posY = 0.2018071,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6649718,
					sizeY = 0.2819551,
					image = "czan#hd2",
					imageNormal = "czan#hd2",
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
