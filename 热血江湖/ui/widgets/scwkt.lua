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
			name = "k4",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1052538,
			sizeY = 0.1944444,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "z7",
				varName = "item_name",
				posX = 0.5,
				posY = 0.2960601,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.057637,
				sizeY = 0.3650773,
				text = "道具名称",
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk4",
				varName = "item_Bg",
				posX = 0.5,
				posY = 0.6691791,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.5938028,
				sizeY = 0.5714286,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t4",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5323104,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7976579,
					sizeY = 0.8092182,
					image = "items#items_gaojijinengshu.png",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo4",
					varName = "suo",
					posX = 0.1932238,
					posY = 0.2388005,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2840885,
					sizeY = 0.2811293,
					image = "tb#tb_suo.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z8",
				varName = "item_count",
				posX = 0.5000001,
				posY = 0.1249399,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.057637,
				sizeY = 0.3650773,
				text = "500/3222",
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a4",
				varName = "tip_btn",
				posX = 0.5,
				posY = 0.7083501,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8175752,
				sizeY = 0.698229,
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
