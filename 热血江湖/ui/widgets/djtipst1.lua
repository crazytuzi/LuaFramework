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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.18,
			sizeY = 0.12,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "item_name",
				posX = 0.3399408,
				posY = 0.7235954,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6257807,
				sizeY = 0.424081,
				text = "装备名字七个字+11",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zbd1",
				varName = "itemBgItem",
				posX = 0.8081613,
				posY = 0.4884259,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3555828,
				sizeY = 0.9582019,
				image = "djk#kbai",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zb1",
				varName = "item_icon",
				posX = 0.8083586,
				posY = 0.5161289,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2759261,
				sizeY = 0.735803,
				image = "items#xueping1.png",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj1",
				varName = "item_level",
				posX = 0.3399408,
				posY = 0.3272308,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6257808,
				sizeY = 0.424081,
				text = "LV:123",
				vTextAlign = 1,
			},
		},
		},
	},
	},
}
--EDITOR elements end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
