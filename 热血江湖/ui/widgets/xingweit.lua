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
			name = "k7",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1546875,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "z13",
				varName = "name",
				posX = 0.6994092,
				posY = 0.7217937,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5965493,
				sizeY = 0.5,
				text = "道具名称",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk7",
				varName = "itemBorder",
				posX = 0.188087,
				posY = 0.48,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4090909,
				sizeY = 0.8888889,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t7",
					varName = "itemIcon",
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
					name = "suo7",
					varName = "lockImg",
					posX = 0.2162216,
					posY = 0.2616932,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3368421,
					sizeY = 0.3333333,
					image = "tb#tb_suo.png",
				},
			},
			{
				prop = {
					etype = "RichText",
					name = "a",
					varName = "num",
					posX = 1.73175,
					posY = 0.2701358,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.408915,
					sizeY = 0.48645,
					text = "500/3222",
					fontSize = 18,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a9",
				varName = "btn",
				posX = 0.1855549,
				posY = 0.5121936,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4038837,
				sizeY = 0.8630201,
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
