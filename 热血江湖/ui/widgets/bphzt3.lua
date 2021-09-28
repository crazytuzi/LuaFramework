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
			name = "wbjd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5576779,
			sizeY = 0.05269046,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "wb",
				posX = 0.5,
				posY = 0.4475558,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9999998,
				sizeY = 0.8947454,
				text = "1.合照功能支援10至150人大型合照",
				color = "FF966856",
				fontSize = 18,
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
