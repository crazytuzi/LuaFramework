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
			name = "jid",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2289062,
			sizeY = 0.125,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "mbt",
				varName = "button",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.8,
				image = "rw#mwd1",
				imageNormal = "rw#mwd1",
				imagePressed = "rw#mwd2",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "mwdm",
				varName = "title",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7327325,
				sizeY = 0.6352749,
				text = "一代宗师",
				color = "FFC14326",
				fontSize = 24,
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
