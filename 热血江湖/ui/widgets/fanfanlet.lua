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
			posX = 0.5009377,
			posY = 0.4750927,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.07612114,
			sizeY = 0.1857,
		},
		children = {
		{
			prop = {
				etype = "Sprite3D",
				name = "mm",
				varName = "model",
				posX = 0.4918452,
				posY = 0.420842,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7703698,
				sizeY = 0.7849804,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "anjiu",
				varName = "btn",
				posX = 0.4825958,
				posY = 0.4278266,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6454168,
				sizeY = 0.7112828,
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
