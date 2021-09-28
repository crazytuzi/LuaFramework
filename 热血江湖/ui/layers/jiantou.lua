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
			name = "jt",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "guangquan",
				posX = 0.5007812,
				posY = 0.5110937,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.07548439,
				sizeY = 0.1341945,
				image = "uieffect/RingGlowWhite21.png",
				alpha = 0,
				blendFunc = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "jiantou",
				posX = 0.5007801,
				posY = 0.6234089,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1,
				sizeY = 0.1777778,
				image = "uieffect/jt.png",
				alpha = 0,
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
	jiantou = {
		jiantou = {
			move = {{0, {640.9985,448.8544,0}}, {250, {640.9985, 420, 0}}, {800, {640.9985,448.8544,0}}, },
			alpha = {{0, {1}}, },
		},
		guangquan = {
			scale = {{0, {1.2, 1.2, 1}}, {250, {1.7, 1.7, 1}}, {800, {1.2, 1.2, 1}}, },
			alpha = {{0, {0}}, {250, {0.7}}, {800, {0}}, },
		},
	},
	c_jiantou = {
		{0,"jiantou", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
