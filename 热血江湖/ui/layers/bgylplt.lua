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
			sizeX = 1.00382,
			sizeY = 1.006678,
			image = "b#dd",
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				posX = 0.501165,
				posY = 0.4993107,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9937822,
				sizeY = 0.9931148,
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
			posX = 0.4996093,
			posY = 0.5006931,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1.000699,
			sizeY = 0.9941995,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "background",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9993015,
				sizeY = 1.005834,
				image = "baiguiyexing1#baiguiyexing1",
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "closeBtn",
				posX = 0.8038172,
				posY = 0.8055272,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1007108,
				sizeY = 0.1327142,
				image = "baiguiyuling#guanbi",
				imageNormal = "baiguiyuling#guanbi",
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
