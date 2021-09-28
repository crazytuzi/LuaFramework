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
			name = "p2",
			varName = "normalBg1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.05859373,
			sizeY = 0.1041667,
			image = "djk#ktong",
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "p3",
				varName = "normalIcon1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.8247142,
				sizeY = 0.8247142,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "dj",
				varName = "normalBtn1",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "xz1",
				varName = "normalNum1",
				posX = 0.4315561,
				posY = 0.2028787,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9622052,
				sizeY = 0.6445522,
				text = "x155",
				fontSize = 18,
				fontOutlineEnable = true,
				hTextAlign = 2,
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
