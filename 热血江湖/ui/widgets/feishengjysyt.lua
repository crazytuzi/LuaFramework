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
			name = "jies",
			posX = 0.5,
			posY = 0.5040579,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0855085,
			sizeY = 0.15,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dj",
				varName = "rank_img",
				posX = 0.5,
				posY = 0.5833337,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7491945,
				sizeY = 0.7592592,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djt",
					varName = "item_img",
					posX = 0.5021798,
					posY = 0.5141602,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8235249,
					sizeY = 0.8304451,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "slz",
					varName = "num_text",
					posX = 0.5386696,
					posY = 0.1975156,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.750474,
					sizeY = 0.6843421,
					text = "x1",
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
				etype = "Button",
				name = "diji",
				varName = "item_btn",
				posX = 0.4913632,
				posY = 0.5582182,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8016704,
				sizeY = 0.7806492,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jyz",
				varName = "desc_text",
				posX = 0.5,
				posY = 0.1237776,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.139171,
				sizeY = 0.5403089,
				text = "6600",
				color = "FF966856",
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
