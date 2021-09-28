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
			etype = "Grid",
			name = "renwu",
			varName = "taskRoot",
			posX = 0.9180776,
			posY = 0.8835866,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1576897,
			sizeY = 0.2263464,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "gb",
				varName = "btn",
				posX = -0.5277148,
				posY = 0.7825269,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4756176,
				sizeY = 0.3068061,
				image = "ty#sn1",
				imageNormal = "ty#sn1",
				disablePressScale = true,
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "zjz",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.254241,
					sizeY = 0.8389441,
					text = "战 况",
					color = "FF634624",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
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
	gy = {
	},
	gy2 = {
	},
	gy3 = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
