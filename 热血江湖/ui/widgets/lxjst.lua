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
			name = "jjpht",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.078125,
			sizeY = 0.1527778,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "tpm2",
				varName = "item_count",
				posX = 0.5000006,
				posY = 0.1295,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.690013,
				sizeY = 0.2640615,
				text = "4.",
				color = "FF966856",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj1",
				varName = "icon_bg",
				posX = 0.4892868,
				posY = 0.6039652,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8299999,
				sizeY = 0.7545453,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt1",
					varName = "item_icon",
					posX = 0.499981,
					posY = 0.5276311,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8108343,
					sizeY = 0.8282878,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "an1",
					varName = "btn",
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
					name = "suo1",
					varName = "suo",
					posX = 0.2026743,
					posY = 0.2376662,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3384071,
					sizeY = 0.3456846,
					image = "tb#suo",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "bz",
					varName = "leader",
					posX = 0.2071314,
					posY = 0.6864435,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.3733333,
					sizeY = 0.6133333,
					image = "wdh#bz",
				},
			},
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
