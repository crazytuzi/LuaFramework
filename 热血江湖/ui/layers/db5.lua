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
				etype = "Button",
				name = "zza",
				varName = "closebtn",
				posX = 0.4832102,
				posY = 0.203148,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.4063233,
				sizeY = 0.3881041,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt5",
				posX = 0.5,
				posY = 0.2,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1.25,
				sizeY = 0.4,
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
				posY = 0.2,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 0.4,
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
					posX = 0.6400281,
					posY = 0.8017055,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.674721,
					sizeY = 0.329646,
					text = "你好，我是谁谁。请问找我有什么事？",
					fontSize = 24,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "btn_scroll",
					posX = 0.4815341,
					posY = 0.359421,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.3818159,
					sizeY = 0.6249999,
					showScrollBar = false,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				posX = 0.3210512,
				posY = 0.4325384,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2304688,
				sizeY = 0.06547619,
				image = "l#mzd",
			},
			children = {
			{
				prop = {
					etype = "Label",
					name = "top",
					varName = "npcName",
					posX = 0.5305085,
					posY = 0.504329,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8244094,
					sizeY = 1.515152,
					text = "NPC名字",
					color = "FFFFFF00",
					fontSize = 26,
					hTextAlign = 1,
					vTextAlign = 1,
				},
			},
			{
				prop = {
					etype = "Label",
					name = "top2",
					varName = "des",
					posX = 1.995608,
					posY = 0.5043295,
					anchorX = 0.5,
					anchorY = 0.5,
					visible = false,
					sizeX = 1.844427,
					sizeY = 1.515152,
					text = "城战专用提示",
					fontSize = 22,
					vTextAlign = 1,
				},
			},
			},
		},
		{
			prop = {
				etype = "Sprite3D",
				name = "mx",
				varName = "npcmodule",
				posX = 0.1189844,
				posY = -0.2512159,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2238505,
				sizeY = 1.275682,
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
