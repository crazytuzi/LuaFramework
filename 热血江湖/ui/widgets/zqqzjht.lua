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
			name = "scczt",
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1015625,
			sizeY = 0.175,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "tip_btn",
				posX = 0.5,
				posY = 0.5238096,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9,
				sizeY = 0.9,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx1",
				varName = "item_BgIcon",
				posX = 0.5,
				posY = 0.5984493,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7230769,
				sizeY = 0.7460318,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "txt1",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5131912,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.83,
					sizeY = 0.83,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xx1",
					varName = "suo",
					posX = 0.203631,
					posY = 0.2243853,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.319149,
					sizeY = 0.3191489,
					image = "tb#suo",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl2",
				varName = "item_count",
				posX = 0.5,
				posY = 0.1552658,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.068226,
				sizeY = 0.25,
				text = "654321",
				color = "FF966856",
				fontOutlineColor = "FF400000",
				hTextAlign = 1,
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
