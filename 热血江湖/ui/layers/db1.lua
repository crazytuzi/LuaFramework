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
			etype = "Image",
			name = "ddd",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 1,
			sizeY = 1,
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
				varName = "close_btn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
				soundEffectClick = "audio/rxjh/UI/anniu.ogg",
			},
		},
		},
	},
	{
		prop = {
			etype = "Grid",
			name = "xxysjm",
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
				etype = "Sprite3D",
				name = "mx",
				varName = "leftModule",
				posX = 0.1189844,
				posY = -0.3643096,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2238505,
				sizeY = 1.275682,
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx2",
				varName = "rightModule",
				posX = 0.88,
				posY = -0.3643096,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2238505,
				sizeY = 1.275682,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt5",
				posX = 0.5,
				posY = 0.1729214,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.25,
				sizeY = 0.3458426,
				image = "l#db",
				scale9 = true,
				scale9Left = 0.35,
				scale9Right = 0.6,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt1",
				posX = 0.5,
				posY = 0.1729214,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.3458426,
				scale9 = true,
				scale9Left = 0.35,
				scale9Right = 0.6,
			},
			children = {
			{
				prop = {
					etype = "RichText",
					name = "dbz",
					varName = "dialogue",
					posX = 0.5,
					posY = 0.4954632,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6933926,
					sizeY = 0.8220658,
					text = "对白剧情写吧三四行都可以的",
					fontSize = 24,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "mzd",
					posX = 0.865025,
					posY = 1.101399,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2304688,
					sizeY = 0.1893237,
					image = "l#mzd",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tsz",
					posX = 0.8650249,
					posY = 1.096528,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1304688,
					sizeY = 0.1204787,
					image = "l#tg",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "zs1",
					posX = 0.9398615,
					posY = 1.095694,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.00859375,
					sizeY = 0.07458205,
					image = "l#zs",
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "js1",
				varName = "npc_icon",
				posX = 0.03124713,
				posY = 0.2365521,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				lockHV = true,
				sizeX = 0.04964647,
				sizeY = 0.1260862,
				image = "halfbody#halfbody01.png",
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
