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
			name = "k10",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.15625,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "z19",
				varName = "name",
				posX = 0.7628689,
				posY = 0.6677976,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6523223,
				sizeY = 0.5,
				text = "道具名称",
				color = "FF81453B",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "djk10",
				varName = "bg",
				posX = 0.218087,
				posY = 0.48,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.41,
				sizeY = 0.8199999,
				image = "djk#kbai",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t10",
					varName = "icon",
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
					name = "suo10",
					varName = "suo",
					posX = 0.2162216,
					posY = 0.2616932,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3368421,
					sizeY = 0.3333333,
					image = "tb#tb_suo.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "z20",
				varName = "count",
				posX = 0.715446,
				posY = 0.3229562,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5574762,
				sizeY = 0.35,
				text = "500/3222",
				color = "FF81453B",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "a12",
				varName = "btn",
				posX = 0.2284358,
				posY = 0.4888075,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4153006,
				sizeY = 0.8342211,
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
	gy = {
	},
	gy3 = {
	},
	gy2 = {
	},
	gy4 = {
	},
	gy5 = {
	},
	gy6 = {
	},
	gy7 = {
	},
	gy8 = {
	},
	gy9 = {
	},
	gy10 = {
	},
	gy11 = {
	},
	gy12 = {
	},
	gy13 = {
	},
	gy14 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
