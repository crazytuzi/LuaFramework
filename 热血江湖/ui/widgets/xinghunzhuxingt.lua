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
			sizeX = 0.4,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "di",
				posX = 0.505851,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8,
				sizeY = 0.6,
				image = "d#bt",
				scale9Left = 0.4,
				scale9Right = 0.4,
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "szy",
				posX = 0.1197662,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1953125,
				sizeY = 1,
				image = "xinghun#zyd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "wh",
					varName = "wenhao",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.46,
					sizeY = 0.6111111,
					image = "xinghun#wen",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zyt",
				varName = "icon",
				posX = 0.1171763,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.08789063,
				sizeY = 0.5,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "msz",
				varName = "desc",
				posX = 0.5647874,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6944187,
				sizeY = 0.6712779,
				text = "对什么职业xxxx",
				color = "FF966856",
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
