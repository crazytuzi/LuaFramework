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
			etype = "Button",
			name = "ddd",
			varName = "bg",
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
			etype = "Grid",
			name = "d9",
			varName = "DigingPanel",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.5066907,
			sizeY = 0.1194444,
			layoutType = 2,
			layoutTypeW = 2,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bbb",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2374476,
				sizeY = 1.546512,
				image = "cs#csd",
				scale9Left = 0.4,
				scale9Right = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "css",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8506494,
					sizeY = 0.9849625,
					image = "cs#csd2",
				},
			},
			{
				prop = {
					etype = "ProgressTimer",
					name = "lq",
					varName = "Digloadingbar",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8506494,
					sizeY = 0.9849625,
					image = "cs#cst",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tsz",
					varName = "Digtipstext",
					posX = 0.5,
					posY = -0.1379638,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.704935,
					sizeY = 0.3302382,
					text = "采集中......",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF8F4E1B",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "gbn",
				varName = "Digcancel",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3109488,
				sizeY = 2.345003,
				propagateToChildren = true,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
			children = {
			{
				prop = {
					etype = "Button",
					name = "qxan",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4909005,
					sizeY = 0.4909005,
					image = "zdte#qx",
					imageNormal = "zdte#qx",
					disableClick = true,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "qx",
					posX = 0.5,
					posY = 0.4999999,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9077845,
					sizeY = 1.115898,
					text = "取 消",
					fontSize = 22,
					fontOutlineEnable = true,
					fontOutlineColor = "FF8F4E1B",
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
	gy = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
