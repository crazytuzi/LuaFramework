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
			name = "xxysjm",
			varName = "skillBtnUI",
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
				name = "smd",
				varName = "chatView",
				posX = 0.4212826,
				posY = 0.1557407,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.521875,
				sizeY = 0.2777778,
				scale9 = true,
				scale9Left = 0.3,
				scale9Right = 0.3,
				scale9Top = 0.3,
				scale9Bottom = 0.3,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tp1",
					posX = 0.3866939,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.7733878,
					sizeY = 0.9928572,
					image = "zbjm#z",
					scale9 = true,
					scale9Left = 0.8,
					scale9Right = 0.1,
				},
			},
			{
				prop = {
					etype = "Image",
					name = "tp2",
					posX = 0.8829576,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.2340848,
					sizeY = 0.9928572,
					image = "zbjm#y",
					scale9 = true,
					scale9Left = 0.1,
					scale9Right = 0.8,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "tda",
					varName = "btnDrag",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					disablePressScale = true,
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt1",
					varName = "btnStop",
					posX = 0.105112,
					posY = 0.4960294,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1197605,
					sizeY = 0.6571429,
					image = "zbjm#tz1",
					imageNormal = "zbjm#tz1",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt2",
					varName = "btnPause",
					posX = 0.2960109,
					posY = 0.4960294,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1197605,
					sizeY = 0.6571429,
					image = "zbjm#zt1",
					imageNormal = "zbjm#zt1",
					imagePressed = "zbjm#zt2",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt3",
					varName = "btnCamera",
					posX = 0.4869099,
					posY = 0.4960294,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1197605,
					sizeY = 0.6571429,
					image = "zbjm#jt1",
					imageNormal = "zbjm#jt1",
					imagePressed = "zbjm#jt2",
				},
			},
			{
				prop = {
					etype = "Button",
					name = "bt4",
					varName = "btnMic",
					posX = 0.6778088,
					posY = 0.4960294,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.1197605,
					sizeY = 0.6571429,
					image = "zbjm#ht1",
					imageNormal = "zbjm#ht1",
					imagePressed = "zbjm#ht2",
				},
			},
			{
				prop = {
					etype = "Label",
					name = "sj",
					varName = "labelTime",
					posX = 0.879793,
					posY = 0.4902549,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.21762,
					sizeY = 0.4694383,
					text = "33:55",
					fontSize = 34,
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
