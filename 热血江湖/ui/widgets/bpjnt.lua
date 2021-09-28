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
			name = "jnj1",
			posX = 0.501269,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.2429688,
			sizeY = 0.1277778,
		},
		children = {
		{
			prop = {
				etype = "Button",
				name = "jna1",
				varName = "skill_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				disablePressScale = true,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "jnxz",
					varName = "select_bg",
					posX = 0.4913191,
					posY = 0.4870461,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6077708,
					sizeY = 0.6252066,
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.2,
					scale9Bottom = 0.2,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnk",
					varName = "skill_bg",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.98,
					sizeY = 0.98,
					image = "b#scd1",
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnb",
					varName = "skill_icon",
					posX = 0.1698173,
					posY = 0.5081021,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2250803,
					sizeY = 0.7608694,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jnd",
					posX = 0.1699235,
					posY = 0.4972323,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2366499,
					sizeY = 0.8152173,
					image = "bp#bp_jnk.png",
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jnm1",
				varName = "skill_name",
				posX = 0.6285541,
				posY = 0.6908073,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5576505,
				sizeY = 0.4196016,
				text = "技能名字一串",
				color = "FF966856",
				fontSize = 22,
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "jndj",
				varName = "skill_lvl",
				posX = 0.6071425,
				posY = 0.3087711,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.5074077,
				sizeY = 0.4369882,
				text = "Lv.  16",
				color = "FF966856",
				fontSize = 22,
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
