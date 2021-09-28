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
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.10625,
			sizeY = 0.1915913,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "bg2#szd",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "btn",
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
				etype = "Image",
				name = "xz",
				varName = "choose_icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "bg2#db",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "item_bg",
				posX = 0.509117,
				posY = 0.604908,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6029412,
				sizeY = 0.5944367,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "item_icon",
					posX = 0.5048133,
					posY = 0.5184065,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8092796,
					sizeY = 0.8122066,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "item_count",
					posX = 0.5609674,
					posY = 0.2001017,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7219349,
					sizeY = 0.7747967,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mz",
					varName = "item_name",
					posX = 0.5,
					posY = -0.1665888,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.51898,
					sizeY = 0.7872788,
					text = "道具名称六字",
					color = "FF966856",
					fontSize = 18,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
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
