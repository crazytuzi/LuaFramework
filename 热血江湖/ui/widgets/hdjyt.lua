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
			name = "p6",
			varName = "bg",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.06640625,
			sizeY = 0.1180556,
			image = "djk#ktong",
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "p61",
				varName = "icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8177969,
				sizeY = 0.7965627,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "b61",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.054062,
				sizeY = 0.9905934,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "w61",
				varName = "count",
				posX = 0.4501752,
				posY = 0.2434827,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8496654,
				sizeY = 0.5020479,
				text = "10",
				fontSize = 18,
				fontOutlineEnable = true,
				hTextAlign = 2,
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
