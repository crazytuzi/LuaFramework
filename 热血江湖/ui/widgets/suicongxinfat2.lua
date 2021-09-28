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
			name = "tp2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2414062,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "tpk2",
				varName = "select",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9482202,
				sizeY = 0.8666667,
				image = "sui#mr",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "fg2",
				posX = 0.4967638,
				posY = 0.5333334,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.9223303,
				sizeY = 0.7777778,
				image = "sui#zdt",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "fwb",
				varName = "label",
				posX = 0.5032268,
				posY = 0.5111111,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7689632,
				sizeY = 0.7750056,
				text = "战绩3500解琐",
				color = "FFFEF487",
				fontSize = 26,
				fontOutlineEnable = true,
				fontOutlineColor = "FF63411D",
				fontOutlineSize = 2,
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "bt",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
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
	gy2 = {
	},
	gy3 = {
	},
	gy4 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
