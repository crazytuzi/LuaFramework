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
			name = "k",
			varName = "root",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1015625,
			sizeY = 0.1805556,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.5643893,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6769231,
				sizeY = 0.6769231,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5090262,
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
					name = "suo",
					varName = "suo",
					posX = 0.2023105,
					posY = 0.2362845,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3529412,
					sizeY = 0.3492647,
					image = "tb#tb_suo.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "item_count",
				posX = 0.5,
				posY = 0.117728,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.197051,
				sizeY = 0.5,
				text = "500/3222",
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "btn",
				posX = 0.5038338,
				posY = 0.5806373,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6834863,
				sizeY = 0.6527705,
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
