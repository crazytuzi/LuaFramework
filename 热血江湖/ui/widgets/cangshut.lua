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
			posX = 0.5028733,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.078125,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an3",
				varName = "globel_btn",
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
				name = "zb",
				varName = "itemBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.95,
				sizeY = 0.9599999,
				image = "djk#ktong",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "zbt",
					varName = "iron",
					posX = 0.5,
					posY = 0.5416668,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "suo",
					posX = 0.1846427,
					posY = 0.2096098,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2631579,
					sizeY = 0.2604167,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sjk",
					varName = "itemBg2",
					posX = 0.4894737,
					posY = 0.5416668,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8421053,
					sizeY = 0.84375,
					image = "ll#sjk",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "countLabel",
					posX = 0.5408556,
					posY = 0.1932244,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7236695,
					sizeY = 0.4681854,
					text = "x55",
					fontSize = 18,
					fontOutlineEnable = true,
					fontOutlineColor = "FF102E21",
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "xhd",
					varName = "red_point",
					posX = 0.8468524,
					posY = 0.8639557,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2842105,
					sizeY = 0.2916667,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xzk",
				varName = "ironBg",
				posX = 0.5,
				posY = 0.53,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1.04,
				sizeY = 1.04,
				image = "djk#zbxz",
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
