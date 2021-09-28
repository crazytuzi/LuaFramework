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
			name = "k",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.265625,
			sizeY = 0.05,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt4",
				varName = "propertyBg2",
				posX = 0.5,
				posY = 0.02222222,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.923077,
				sizeY = 0.04444445,
				image = "d2#fgx",
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "propertyName",
				posX = 0.3174644,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2882399,
				sizeY = 1.388889,
				text = "气血:",
				color = "FF966856",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z2",
				varName = "propertyValue",
				posX = 0.8986865,
				posY = 0.4444444,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.309871,
				sizeY = 1.388889,
				text = "6500",
				color = "FF76D646",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FF5B7838",
				fontOutlineSize = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "propertyIcon",
				posX = 0.08913568,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1058824,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				posX = 0.704457,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.02910603,
				sizeY = 0.3333333,
				image = "chu1#jt",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z3",
				varName = "valueMid",
				posX = 0.5928017,
				posY = 0.4444444,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.309871,
				sizeY = 1.388889,
				text = "6500",
				color = "FFF1E9D7",
				fontSize = 18,
				fontOutlineEnable = true,
				fontOutlineColor = "FFA47848",
				fontOutlineSize = 2,
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
