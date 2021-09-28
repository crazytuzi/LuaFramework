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
			name = "dj1",
			varName = "bt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			lockHV = true,
			sizeX = 0.07828281,
			sizeY = 0.1388889,
			disablePressScale = true,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dk",
				varName = "grade_icon",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.98,
				sizeY = 0.98,
				image = "djk#ktong",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tp1",
				varName = "item_icon",
				posX = 0.5099798,
				posY = 0.52,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.788,
				sizeY = 0.788,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "hs",
				varName = "is_show",
				posX = 0.4999999,
				posY = 0.5113188,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.7914576,
				sizeY = 0.7930564,
				image = "ty#hong",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "s1",
				varName = "item_count",
				posX = 0.5191829,
				posY = 0.1831578,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.755787,
				sizeY = 0.4377611,
				text = "x22",
				fontOutlineEnable = true,
				fontOutlineColor = "FF102E21",
				hTextAlign = 2,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "kuang",
				varName = "is_select",
				posX = 0.5,
				posY = 0.53,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 1.037903,
				sizeY = 1.04,
				image = "djk#zbxz",
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "suo",
				varName = "suo",
				posX = 0.1973507,
				posY = 0.2209761,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2993952,
				sizeY = 0.3,
				image = "tb#suo",
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jt",
				varName = "isUp",
				posX = 0.7894164,
				posY = 0.79,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.2993952,
				sizeY = 0.3,
				image = "chu1#ss",
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
