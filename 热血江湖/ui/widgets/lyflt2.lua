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
			sizeY = 0.145044,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "tpm2",
				varName = "price",
				posX = 0.5099853,
				posY = 0.1346353,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 2.046629,
				sizeY = 0.4605178,
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
				varName = "grade_icon",
				posX = 0.4892868,
				posY = 0.6029958,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8,
				sizeY = 0.7660511,
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
					varName = "bt",
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
