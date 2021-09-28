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
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3453125,
			sizeY = 0.09722222,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "select_btn",
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
				name = "pt",
				varName = "normalBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "hx#hx2",
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "zdfx",
				varName = "fightBg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1,
				sizeY = 1,
				image = "hx#hx3",
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dq",
				varName = "showselect",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				image = "hx#hx1",
				scale9 = true,
				scale9Left = 0.48,
				scale9Right = 0.48,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jt",
					posX = 0.15,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.04072398,
					sizeY = 0.3142858,
					image = "chu1#jt2",
				},
			},
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "text",
				posX = 0.4785966,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4586365,
				sizeY = 0.9736063,
				text = "一线",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb2",
				varName = "desc",
				posX = 0.6095845,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5759028,
				sizeY = 0.9736063,
				text = "普通分线",
				color = "FF966856",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				hTextAlign = 2,
				vTextAlign = 1,
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
