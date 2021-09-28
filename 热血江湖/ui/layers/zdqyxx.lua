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
			name = "jd",
			posX = 0.5,
			posY = 0.35,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 0.7,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt",
				varName = "findRoot",
				posX = 0.6243162,
				posY = 0.3065589,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.078125,
				sizeY = 0.2190476,
				image = "zdss#qyx",
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "an",
					varName = "transBtn",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "wz1",
					varName = "taskNameLabel",
					posX = 0.4993039,
					posY = 0.4787065,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.7757208,
					sizeY = 0.6834299,
					color = "FF32D6FF",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF102E21",
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
	ss = {
		dt = {
			alpha = {{0, {1}}, {500, {0.3}}, {1000, {1}}, },
		},
	},
	c_dakai = {
		{0,"ss", -1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
