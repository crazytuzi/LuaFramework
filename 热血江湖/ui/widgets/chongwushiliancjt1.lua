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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1757813,
			sizeY = 0.3819444,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "icon",
				varName = "icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9955553,
				sizeY = 1,
				image = "xunyang#lichi",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mc1",
				varName = "name",
				posX = 0.1086644,
				posY = 0.08699207,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6,
				sizeY = 0.25,
				text = "名称",
				color = "FFFBF9F7",
				fontOutlineEnable = true,
				fontOutlineColor = "FF9C4F17",
				fontOutlineSize = 2,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "dj",
				varName = "des",
				posX = 0.7879216,
				posY = 0.08699207,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6185665,
				sizeY = 0.25,
				text = "10/10级",
				color = "FF65944D",
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
