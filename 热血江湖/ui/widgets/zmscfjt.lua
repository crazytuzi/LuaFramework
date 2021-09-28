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
			name = "xtb",
			varName = "bg",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.0734375,
			sizeY = 0.1305556,
			image = "djk#kzi",
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "xtb2",
				varName = "icon",
				posX = 0.500012,
				posY = 0.5276596,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8838297,
				sizeY = 0.8838305,
				image = "items#gaojizhufushi",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "xwb10",
				varName = "count",
				posX = 0.2954528,
				posY = 0.1760638,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.213601,
				sizeY = 0.9027673,
				text = "5",
				fontSize = 18,
				fontOutlineEnable = true,
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "xanb",
				varName = "btn",
				posX = 0.5000041,
				posY = 0.5144655,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.910201,
				sizeY = 0.9233788,
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
