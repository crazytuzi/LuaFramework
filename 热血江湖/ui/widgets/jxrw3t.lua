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
			name = "lb1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.08984375,
			sizeY = 0.1958333,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "bt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				layoutType = 5,
				layoutTypeW = 5,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tl",
				varName = "icon_bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7652174,
				sizeY = 0.6241137,
				image = "djk#ktong",
				scale9Left = 0.2,
				scale9Right = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "item_icon",
					posX = 0.5085554,
					posY = 0.5154309,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7815523,
					sizeY = 0.7594256,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "text5",
					varName = "item_count",
					posX = 0.5,
					posY = -0.1025228,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.400596,
					sizeY = 0.5649222,
					text = "1",
					color = "FF966856",
					fontSize = 18,
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "text6",
					varName = "tip",
					posX = 0.5,
					posY = 1.118974,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.400596,
					sizeY = 0.5649222,
					text = "优先消耗",
					color = "FFC93034",
					fontSize = 18,
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jia",
				varName = "jia",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.6956522,
				sizeY = 0.567376,
				image = "anqi#jia",
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
