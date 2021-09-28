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
			sizeX = 0.1703125,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "mz2",
				varName = "count",
				posX = 0.8961015,
				posY = 0.3113249,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9663045,
				sizeY = 0.5683542,
				text = "x1000",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mz",
				varName = "name",
				posX = 0.8869272,
				posY = 0.6743838,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9663045,
				sizeY = 0.5683542,
				text = "名字最长七个字",
				color = "FF966856",
				fontOutlineColor = "FF614A31",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dj",
				varName = "item_bg",
				posX = 0.1977424,
				posY = 0.4999881,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3899083,
				sizeY = 0.85,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "icon",
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
					etype = "Button",
					name = "an",
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
					name = "suo",
					posX = 0.1947079,
					posY = 0.2298559,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.317647,
					sizeY = 0.317647,
					image = "tb#suo",
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
