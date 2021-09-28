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
			sizeX = 0.24375,
			sizeY = 0.1416398,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "bfmt",
				varName = "bg",
				posX = 0.4867882,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.9735762,
				sizeY = 1,
				image = "b#scd1",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.5,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "xzk",
					varName = "select_icon",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "b#scd2",
					scale9 = true,
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "txk",
					varName = "boos_bg",
					posX = 0.1891152,
					posY = 0.4937292,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.2793451,
					sizeY = 0.8743579,
					image = "bp#bossd",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "tx",
						varName = "boos_icon",
						posX = 0.5,
						posY = 0.4865746,
						anchorX = 0.5,
						anchorY = 0.5,
						lockHV = true,
						sizeX = 0.9026195,
						sizeY = 0.9026195,
						image = "tx#chenshangbi",
					},
				},
				},
			},
			{
				prop = {
					etype = "Label",
					name = "fbm",
					varName = "dungeon_name",
					posX = 0.6626689,
					posY = 0.5138982,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6204073,
					sizeY = 0.4130083,
					text = "副本名称",
					color = "FF966856",
					fontSize = 26,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "suo",
					varName = "lock_icon",
					posX = 0.29602,
					posY = 0.2339412,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1314103,
					sizeY = 0.4118428,
					image = "ty#suo",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "jb",
					varName = "specialIcon",
					posX = 0.9305537,
					posY = 0.7936647,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.09547144,
					sizeY = 0.3824255,
					image = "bp#hun",
				},
			},
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
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
