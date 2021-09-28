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
			name = "renwubaogao",
			varName = "task_result_root",
			posX = 0.5000255,
			posY = 0.4514294,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.8782438,
			sizeY = 0.8225504,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "db",
				posX = 0.5000061,
				posY = 0.4663751,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9502656,
				sizeY = 0.8878695,
				image = "g#g_d9.png",
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "history_scroll",
					posX = 0.5002868,
					posY = 0.4992696,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9860696,
					sizeY = 0.9713054,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "jh4",
				varName = "addchild_btn",
				posX = 0.9522873,
				posY = 0.9580008,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.04981532,
				sizeY = 0.09962239,
				image = "wg#wg_jia.png",
				imageNormal = "wg#wg_jia.png",
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		{
			prop = {
				etype = "RichText",
				name = "waw2",
				varName = "child_count_label",
				posX = 0.761905,
				posY = 0.9595158,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.321315,
				sizeY = 0.09292505,
				text = "闲置普通弟子：300/12500",
				color = "FFC2F9E8",
				fontSize = 24,
				hTextAlign = 2,
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
