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
			name = "k2",
			varName = "node",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2554688,
			sizeY = 0.05,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "t",
				varName = "diamond_bg",
				posX = 0.1722334,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1100917,
				sizeY = 1,
				image = "zdjn#lv",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bst",
					varName = "icon",
					posX = 0.4982332,
					posY = 0.5060849,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7913853,
					sizeY = 0.8157262,
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "sx",
				varName = "desc",
				posX = 0.6629658,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7913757,
				sizeY = 0.9,
				text = "属性什么的",
				color = "FF966856",
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
