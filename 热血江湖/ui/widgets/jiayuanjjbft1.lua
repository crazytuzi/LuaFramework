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
			name = "jied",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.09375,
			sizeY = 0.08055558,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "qh5",
				varName = "type_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1,
				sizeY = 0.9310341,
				image = "jy#fy2",
				imageNormal = "jy#fy2",
				imagePressed = "jy#fy1",
				imageDisable = "jy#fy2",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "hz2",
					varName = "name",
					posX = 0.5,
					posY = 0.4261654,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.564584,
					sizeY = 1.072235,
					text = "装 备",
					color = "FFEBC6B4",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF91634A",
					fontOutlineSize = 2,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
