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
			name = "cc1",
			varName = "bt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.09,
			sizeY = 0.1819444,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk1",
				varName = "icon_bg",
				posX = 0.5118598,
				posY = 0.6712474,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.6944444,
				sizeY = 0.6106871,
				image = "djk#ktong",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "t1",
					varName = "item_icon",
					posX = 0.5,
					posY = 0.5127688,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8,
					sizeY = 0.8,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "aa1",
				varName = "item_name",
				posX = 0.5,
				posY = 0.3021048,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.367307,
				sizeY = 0.3250848,
				text = "道具六个字吧",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "ss1",
				varName = "item_count",
				posX = 0.5052559,
				posY = 0.06505709,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.05,
				sizeY = 0.296635,
				text = "222/333",
				fontSize = 18,
				fontOutlineColor = "FF27221D",
				hTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				varName = "suo",
				posX = 0.3005429,
				posY = 0.4986204,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.2170139,
				sizeY = 0.1908397,
				image = "tb#tb_suo.png",
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
