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
			varName = "itemRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1132813,
			sizeY = 0.2527778,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "cl1",
				varName = "item_btn",
				posX = 0.5,
				posY = 0.643712,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7666667,
				sizeY = 0.6756586,
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "clk",
					varName = "item_bg",
					posX = 0.5,
					posY = 0.4911375,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8455768,
					sizeY = 0.7644148,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "zbt",
						varName = "item_icon",
						posX = 0.4936624,
						posY = 0.5301207,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8125109,
					},
				},
				},
			},
			{
				prop = {
					etype = "Image",
					name = "hd",
					varName = "item_point",
					posX = 0.8589855,
					posY = 0.8370095,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2428785,
					sizeY = 0.227698,
					image = "zdte#hd",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl1",
				varName = "itemName",
				posX = 0.5,
				posY = 0.29042,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.042061,
				sizeY = 0.25,
				text = "什么道具",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "sl2",
				varName = "item_count",
				posX = 0.5,
				posY = 0.09880397,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.042061,
				sizeY = 0.25,
				text = "100、500",
				color = "FF966856",
				fontSize = 22,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
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
