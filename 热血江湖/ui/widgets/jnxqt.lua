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
			name = "jd",
			varName = "rootVar",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2442599,
			sizeY = 0.04583333,
		},
		children = {
		{
			prop = {
				etype = "Grid",
				name = "jie",
				posX = 0.5,
				posY = 1,
				anchorX = 0.5,
				anchorY = 1,
				sizeX = 1,
				sizeY = 1,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "wz6",
					varName = "desc",
					posX = 0.5,
					posY = -0.1666662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9725934,
					sizeY = 2,
					color = "FF714730",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FFEFD4B4",
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
