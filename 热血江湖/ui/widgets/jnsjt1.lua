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
			sizeX = 0.16875,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "z",
				varName = "item_name",
				posX = 0.6994092,
				posY = 0.7217937,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5965493,
				sizeY = 0.5,
				text = "道具名称",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk",
				varName = "item_BgIcon",
				posX = 0.1964819,
				posY = 0.48,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3935185,
				sizeY = 0.8589473,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t",
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
					name = "suo",
					varName = "suo",
					posX = 0.261134,
					posY = 0.3061376,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3981098,
					sizeY = 0.4038795,
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
				posX = 0.6994092,
				posY = 0.2869586,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5965493,
				sizeY = 0.5,
				text = "500/3222",
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a1",
				varName = "tip_btn",
				posX = 0.2209084,
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
