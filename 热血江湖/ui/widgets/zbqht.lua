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
			name = "zbqht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1796875,
			sizeY = 0.05,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "zbqhtz",
				varName = "label",
				posX = 0.348169,
				posY = 0.5403681,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4775194,
				sizeY = 0.9677028,
				text = "物理物理：",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zbqhtz2",
				varName = "value",
				posX = 0.8030823,
				posY = 0.5403679,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6006849,
				sizeY = 0.9677027,
				text = "23134576",
				color = "FFF1E9D7",
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
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
