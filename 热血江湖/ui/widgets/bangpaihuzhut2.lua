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
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0671875,
			sizeY = 0.1180556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djt",
				varName = "reward",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dj",
					varName = "icon",
					posX = 0.5067111,
					posY = 0.5214033,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8456198,
					sizeY = 0.8414971,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.1865497,
					posY = 0.2180913,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.301816,
					sizeY = 0.3053667,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn",
					varName = "iconbt",
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
					name = "sl",
					varName = "num",
					posX = 0.6286323,
					posY = 0.1865944,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6018126,
					sizeY = 0.7357641,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
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
