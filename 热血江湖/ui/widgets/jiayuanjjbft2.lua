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
			name = "jied",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.08628765,
			sizeY = 0.169574,
		},
		children = {
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
				name = "djk",
				varName = "item_bg",
				posX = 0.5,
				posY = 0.5900949,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8510778,
				sizeY = 0.7699031,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "item_icon",
					posX = 0.4986857,
					posY = 0.5146108,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8522738,
					sizeY = 0.8367875,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "mc1",
					varName = "item_name",
					posX = 0.5,
					posY = -0.1226381,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.785591,
					sizeY = 0.539406,
					text = "布拉格屏风",
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sl",
					varName = "item_count",
					posX = 0.3341188,
					posY = 0.1799602,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.181525,
					sizeY = 1.102312,
					text = "x10",
					fontSize = 18,
					fontOutlineEnable = true,
					hTextAlign = 2,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "choose_icon",
				posX = 0.5,
				posY = 0.6146662,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9400561,
				sizeY = 0.850395,
				image = "djk#xz",
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
