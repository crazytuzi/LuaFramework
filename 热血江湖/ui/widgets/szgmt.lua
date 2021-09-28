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
			etype = "Image",
			name = "zld2",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1737327,
			sizeY = 0.04990072,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "zl3",
				varName = "desc",
				posX = 0.3425928,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6503745,
				sizeY = 1.177395,
				text = "战力：",
				color = "FFB5EBEE",
				fontOutlineColor = "FF400000",
				vTextAlign = 1,
				colorTL = "FFF3EE30",
				colorTR = "FFF3EE30",
				colorBR = "FFE77676",
				colorBL = "FFE77676",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "zl4",
				varName = "value",
				posX = 0.9,
				posY = 0.4999997,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6562645,
				sizeY = 1.177395,
				text = "123456",
				color = "FFB5EBEE",
				fontOutlineColor = "FF400000",
				vTextAlign = 1,
				colorTL = "FFF3EE30",
				colorTR = "FFF3EE30",
				colorBR = "FFE77676",
				colorBL = "FFE77676",
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
