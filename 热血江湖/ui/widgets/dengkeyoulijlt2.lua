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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.1065341,
			sizeY = 0.08333334,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj2",
				varName = "item_bg",
				posX = 0.2065254,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.4,
				sizeY = 0.909091,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt2",
					varName = "item_icon",
					posX = 0.4986858,
					posY = 0.5200127,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8310284,
					sizeY = 0.8259836,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl2",
					varName = "item_count",
					posX = 2.168238,
					posY = 0.2781395,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 2.263606,
					sizeY = 0.9109429,
					text = "x100",
					color = "FFD2B1ED",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "btn2",
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
					name = "sl3",
					varName = "item_name",
					posX = 2.672475,
					posY = 0.7156395,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 3.272083,
					sizeY = 0.9109429,
					text = "名字",
					color = "FFD2B1ED",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.2130257,
					posY = 0.2380226,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.35,
					sizeY = 0.35,
					image = "tb#suo",
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
