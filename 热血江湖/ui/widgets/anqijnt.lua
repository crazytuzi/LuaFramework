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
			name = "jd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.078125,
			sizeY = 0.1388889,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "jnd6",
				varName = "bg",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.98,
				sizeY = 0.9499999,
				image = "anqi#lv",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "jn6",
					varName = "btn",
					posX = 0.500437,
					posY = 0.5001152,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6694857,
					sizeY = 0.7390427,
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnt",
					varName = "icon",
					posX = 0.5,
					posY = 0.4789474,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7755103,
					sizeY = 0.8000001,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3061225,
					sizeY = 0.3789474,
					image = "anqi#suo",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "sjjt6",
					varName = "up_arrow",
					posX = 0.8488706,
					posY = 0.1835244,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 0.1836735,
					sizeY = 0.3263158,
					image = "sui#sj",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "xz",
				varName = "selectImg",
				posX = 0.49,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 1.07,
				sizeY = 1.06,
				image = "anqi#xz",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "ztz",
				varName = "desc",
				posX = 0.5,
				posY = 0.166667,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.220704,
				sizeY = 0.6130846,
				text = "未解锁",
				fontOutlineEnable = true,
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
	gy = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
