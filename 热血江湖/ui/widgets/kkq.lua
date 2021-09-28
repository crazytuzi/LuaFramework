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
			etype = "Button",
			name = "kkq",
			posX = 0.5003152,
			posY = 0.4969918,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.08422845,
			sizeY = 0.1600822,
			image = "q#daojukuang.png",
			imageNormal = "q#daojukuang.png",
			imagePressed = "q#daojukuang.png",
			imageDisable = "q#daojukuang.png",
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Label",
				name = "wz",
				posX = 0.5,
				posY = 0.1601598,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9447929,
				sizeY = 0.2500001,
				text = "可开启",
				fontOutlineEnable = true,
				hTextAlign = 1,
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
