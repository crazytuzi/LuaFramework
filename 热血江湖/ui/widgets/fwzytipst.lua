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
			sizeX = 0.2195313,
			sizeY = 0.05277778,
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
				varName = "value",
				posX = 0.7235823,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4632388,
				sizeY = 1.346145,
				text = "666",
				color = "FF76D646",
				fontOutlineEnable = true,
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
				varName = "desc",
				posX = 0.4886913,
				posY = 0.5000008,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6050949,
				sizeY = 1.346626,
				text = "shuxing",
				color = "FF966856",
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "sxt",
				varName = "icon",
				posX = 0.09786689,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1245551,
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
