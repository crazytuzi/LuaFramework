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
			etype = "Image",
			name = "kk1",
			posX = 0.5,
			posY = 0.4577084,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.9078125,
			sizeY = 0.8763889,
			image = "b#db1",
			scale9 = true,
			scale9Left = 0.45,
			scale9Right = 0.45,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "zs1",
				posX = 0.02057244,
				posY = 0.1628659,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.05421687,
				sizeY = 0.3755943,
				image = "zhu#zs1",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zs2",
				posX = 0.9442027,
				posY = 0.1851488,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1592083,
				sizeY = 0.4057052,
				image = "zhu#zs2",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "db2",
				posX = 0.491394,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9363167,
				sizeY = 0.9746434,
				image = "b#db2",
				scale9 = true,
				scale9Left = 0.47,
				scale9Right = 0.47,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "title",
				posX = 0.5,
				posY = 0.9873216,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.07401,
				sizeY = 0.08082409,
				image = "b#top",
				scale9 = true,
				scale9Left = 0.49,
				scale9Right = 0.49,
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
