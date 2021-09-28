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
			name = "bg",
			varName = "roleInfoUI",
			posX = 0.5,
			posY = 0.75,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.5,
			layoutType = 9,
			layoutTypeW = 9,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bg1",
				posX = 0.8696958,
				posY = 0.7146133,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2339737,
				sizeY = 0.5417998,
				image = "hudxlzm#hdxlzmbg",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.2,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bg2",
				posX = 0.8696958,
				posY = 0.9350851,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2339737,
				sizeY = 0.1008562,
				image = "hudxlzm#tt1",
				scale9 = true,
				scale9Left = 0.2,
				scale9Right = 0.2,
				scale9Top = 0.2,
				scale9Bottom = 0.2,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "cc7",
				varName = "totalText",
				posX = 0.8657655,
				posY = 0.9262477,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2200297,
				sizeY = 0.08873889,
				text = "全员掉落增益",
				color = "FFFFFF80",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Scroll",
				name = "list",
				varName = "scroll",
				posX = 0.8702383,
				posY = 0.6674723,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2282431,
				sizeY = 0.4197864,
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
