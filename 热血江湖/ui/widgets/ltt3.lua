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
			name = "xt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.4015625,
			sizeY = 0.1138889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "nrd",
				varName = "imgUI",
				posX = 0.574156,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.815227,
				sizeY = 0.95,
				scale9 = true,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "pd3",
				varName = "set_image",
				posX = 0.1204503,
				posY = 0.7428617,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1342412,
				sizeY = 0.2560975,
				image = "lt#xt",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "xtnr",
				varName = "b",
				posX = 0.5968506,
				posY = 0.4671946,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7636452,
				sizeY = 0.8218336,
				text = "长度自我调整，这个太关键了。一定要自我调整。",
				color = "FFFF3D10",
				fontSize = 22,
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
