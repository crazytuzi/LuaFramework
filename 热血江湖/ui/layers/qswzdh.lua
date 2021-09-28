--version = 1
local l_fileType = "layer"

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
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.1,
			scale9Right = 0.1,
			scale9Top = 0.1,
			scale9Bottom = 0.1,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "closeBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.88,
			sizeY = 0.98,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "hei",
				varName = "blackIcon",
				posX = 0.4995564,
				posY = 0.5014148,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.133613,
				sizeY = 1.013074,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb",
				varName = "text",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "动画",
				fontSize = 26,
				hTextAlign = 1,
				vTextAlign = 1,
				alpha = 0,
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
	danru = {
		wb = {
			alpha = {{0, {0}}, {1000, {1}}, },
		},
	},
	danchu = {
		wb = {
			alpha = {{0, {1}}, {1000, {0}}, },
		},
	},
	c_tanchu = {
		{0,"danru", 1, 0},
		{0,"danchu", 1, 3000},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
