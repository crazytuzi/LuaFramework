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
				posX = 0.2916476,
				posY = 0.5403681,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4775194,
				sizeY = 0.9677028,
				text = "物理上海",
				color = "FF634624",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zbqhtz2",
				varName = "value",
				posX = 0.8030187,
				posY = 0.5125901,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7570784,
				sizeY = 0.9677027,
				text = "+99% +9999",
				color = "FF029133",
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
