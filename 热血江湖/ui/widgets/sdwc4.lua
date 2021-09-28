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
			name = "lbjd",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.06826738,
			sizeY = 0.1209698,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "icon_bg",
				posX = 0.4947968,
				posY = 0.4999983,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.98,
				sizeY = 0.9827922,
				image = "djk#kbai",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "t",
				varName = "item_icon",
				posX = 0.4885602,
				posY = 0.5343843,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7997358,
				sizeY = 0.8023598,
				image = "items#items_gaojijinengshu.png",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an1",
				varName = "item_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl",
				varName = "countLabel",
				posX = 0.5785935,
				posY = 0.2412469,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6427473,
				sizeY = 0.4001039,
				text = "x11",
				fontOutlineEnable = true,
				fontOutlineColor = "FF27221D",
				hTextAlign = 2,
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
