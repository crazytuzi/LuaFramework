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
			name = "qm9",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.24375,
			sizeY = 0.04983371,
		},
		children = {
		{
			prop = {
				etype = "RichText",
				name = "js9",
				varName = "value",
				posX = 0.7719108,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7937189,
				sizeY = 1.532876,
				text = "66666",
				color = "FFEDE160",
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc10",
				varName = "desc",
				posX = 0.2466924,
				posY = 0.5000006,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.344984,
				sizeY = 1.532876,
				text = "气血：",
				color = "FFDEA484",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "max",
				varName = "max_img",
				posX = 0.845683,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2179487,
				sizeY = 0.7525027,
				image = "gf#max",
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
