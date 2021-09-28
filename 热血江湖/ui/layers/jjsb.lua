--version = 1
local l_fileType = "layer"

local UIUtil = require "ui/common/UIUtil"

--EDITOR elements start tag
local eleRoot = 
{
	prop = {
		etype = "Layer",
		name = "root",
		varName = "Bonuspanel",
		posX = 0,
		posY = 0,
		anchorX = 0,
		anchorY = 0,
		soundEffectOpen = "audio/rxjh/UI/ui_lose.ogg",
	},
	children = {
	{
		prop = {
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
			image = "b#dd",
			scale9 = true,
			scale9Left = 0.2,
			scale9Right = 0.2,
			scale9Top = 0.2,
			scale9Bottom = 0.2,
			alpha = 0.7,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "dd",
				varName = "exitBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
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
				name = "dt",
				posX = 0.5,
				posY = 0.4829454,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.9742247,
				alpha = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "top",
					posX = 0.5,
					posY = 0.8326306,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4476562,
					sizeY = 0.1967376,
					image = "js#js_zdsb.png",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "tcsj",
					varName = "daojishi",
					posX = 0.5,
					posY = 0.1723337,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.4081687,
					sizeY = 0.1209797,
					text = "稍后自动退出战斗、点击空白区域退出",
					color = "FFF0F9A6",
					fontSize = 24,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Grid",
				name = "kk2",
				posX = 0.5,
				posY = 0.4578842,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.7113292,
				sizeY = 0.5041356,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "bjt",
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
					name = "wb1",
					posX = 0.5,
					posY = 0.8108016,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6,
					sizeY = 0.25,
					text = "推荐通过以下方式提升战力",
					fontSize = 22,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "img_scroll",
					posX = 0.5,
					posY = 0.4392422,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.658552,
					sizeY = 0.3715157,
					horizontal = true,
					showScrollBar = false,
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
