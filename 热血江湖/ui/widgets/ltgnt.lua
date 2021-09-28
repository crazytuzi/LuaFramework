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
			etype = "Button",
			name = "ltgnt",
			varName = "btn",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1015625,
			sizeY = 0.08888889,
			disablePressScale = true,
			propagateToChildren = true,
			soundEffectClick = "audio/rxjh/UI/anniu.ogg",
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dz",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9538462,
				sizeY = 0.90625,
				image = "chu1#sn1",
				imageNormal = "chu1#sn1",
				disablePressScale = true,
				disableClick = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "z1",
				varName = "btnName",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9629171,
				sizeY = 0.7986809,
				text = "邀请组队",
				color = "FF914A15",
				fontSize = 24,
				fontOutlineColor = "FF936D51",
				fontOutlineSize = 2,
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
