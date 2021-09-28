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
			name = "k1",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.734375,
			sizeY = 0.7027778,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "smd",
				posX = 0.5,
				posY = 0.924197,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.1302218,
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				alpha = 0.5,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "haoyou",
				varName = "ShouChong",
				posX = 0.5,
				posY = 0.4265868,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.8531738,
				image = "b#d2",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.45,
				scale9Bottom = 0.45,
			},
			children = {
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "friend_scroll",
					posX = 0.5,
					posY = 0.5004832,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.988269,
					sizeY = 0.9758013,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an10",
				varName = "find_btn",
				posX = 0.6100729,
				posY = 0.9240849,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1319149,
				sizeY = 0.1146245,
				image = "chu1#sn1",
				imageNormal = "chu1#sn1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z4",
					varName = "GetBtnText3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.016411,
					sizeY = 0.8880838,
					text = "查 找",
					color = "FF914A15",
					fontSize = 24,
					fontOutlineColor = "FF8DE3C4",
					fontOutlineSize = 2,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "srk",
				posX = 0.2673447,
				posY = 0.922231,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5014192,
				sizeY = 0.1166008,
				image = "chu1#sxd",
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
			},
			children = {
			{
				prop = {
					etype = "EditBox",
					name = "sr",
					sizeXAB = 429.1277,
					sizeYAB = 47.90315,
					posXAB = 233.808,
					posYAB = 29.5,
					varName = "editbox",
					posX = 0.4960558,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.9104535,
					sizeY = 0.8119177,
					color = "FFF1DDC1",
					fontSize = 24,
					vTextAlign = 1,
					phText = "输入ID查找",
					phColor = "FFF1DDC1",
					phFontSize = 24,
					autoWrap = false,
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an9",
				varName = "sysrecommend",
				posX = 0.8901526,
				posY = 0.9181559,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.1851064,
				sizeY = 0.1304348,
				image = "chu1#an1",
				imageNormal = "chu1#an1",
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "z3",
					varName = "GetBtnText2",
					posX = 0.5,
					posY = 0.5454545,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.016411,
					sizeY = 0.8880838,
					text = "系统推荐",
					fontSize = 24,
					fontOutlineEnable = true,
					fontOutlineColor = "FFB35F1D",
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
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
