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
			name = "jiad",
			varName = "rootVar",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3011649,
			sizeY = 0.04444445,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "ms4",
				varName = "desc",
				posX = 0.5000001,
				posY = 1,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 0.9999999,
				sizeY = 1.818922,
				text = "描述1",
				color = "FFB5886A",
				fontSize = 18,
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
