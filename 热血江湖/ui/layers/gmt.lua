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
			name = "ysjm",
			varName = "moveRoot",
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
				etype = "Button",
				name = "a2",
				varName = "backBtn",
				posX = 0.328049,
				posY = 0.9396547,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1029829,
				sizeY = 0.06944445,
				image = "chu1#an2",
				imageNormal = "chu1#an2",
				soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "wz2",
					varName = "cancel_word2",
					posX = 0.4999998,
					posY = 0.546875,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8313715,
					sizeY = 0.8905213,
					text = "后台",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FF2A6953",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "ns",
					varName = "test_num",
					posX = 0.5,
					posY = -0.2768621,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.325922,
					sizeY = 0.6455749,
					text = "122345151",
					color = "FFFFFF00",
					hTextAlign = 1,
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
