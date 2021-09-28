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
			name = "jie",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.0859375,
			sizeY = 0.06944445,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "btn",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9545454,
				sizeY = 0.8,
				image = "zqqz2#an",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				imageNormal = "zqqz2#an",
				imagePressed = "zqqz2#liang",
				imageDisable = "zqqz2#an",
				disablePressScale = true,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wb",
				varName = "name",
				posX = 0.6272726,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.08132,
				sizeY = 0.9836047,
				text = "颜色",
				color = "FFFDE8CD",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tb",
				varName = "img",
				posX = 0.2454548,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2620321,
				sizeY = 0.5599999,
				image = "zqqz2#v1",
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
