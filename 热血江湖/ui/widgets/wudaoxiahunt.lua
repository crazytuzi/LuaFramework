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
			name = "xl1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5632812,
			sizeY = 0.05138889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "yt1",
				posX = 0.5,
				posY = 0.02325582,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.95,
				sizeY = 0.04651163,
				image = "b#xian",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz1",
				varName = "attrValue",
				posX = 0.2649619,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1931355,
				sizeY = 1.346145,
				text = "0",
				color = "FFE5C896",
				fontOutlineColor = "FF5B7838",
				fontOutlineSize = 2,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz2",
				varName = "attrName",
				posX = 0.27208,
				posY = 0.5000008,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2611367,
				sizeY = 1.346626,
				text = "去学",
				color = "FFE5C896",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz3",
				varName = "addValue",
				posX = 0.7406635,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2996333,
				sizeY = 1.346145,
				text = "666",
				color = "FFA3FF59",
				fontOutlineColor = "FF5B7838",
				fontOutlineSize = 2,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sxt",
				varName = "icon",
				posX = 0.07100972,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.0485437,
				sizeY = 0.9210526,
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
