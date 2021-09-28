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
			name = "lbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0859375,
			sizeY = 0.1611111,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "bg",
				posX = 0.5,
				posY = 0.6034484,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7727273,
				sizeY = 0.7327586,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "infoBtn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sx",
					varName = "countLabel",
					posX = 0.5,
					posY = -0.1119341,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.72392,
					sizeY = 0.454107,
					text = "100/100",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
					posX = 0.5026645,
					posY = 0.5153987,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7463084,
					sizeY = 0.7594906,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock",
					posX = 0.218108,
					posY = 0.2533519,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3294117,
					sizeY = 0.3294118,
					image = "tb#suo",
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
