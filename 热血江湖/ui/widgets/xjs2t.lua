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
			name = "xjs2t",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.3148437,
			sizeY = 0.1666667,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt1",
				varName = "imgPlayer",
				posX = 0.4181138,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.8411912,
				sizeY = 0.9999998,
				image = "dl#dl_d4.png",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "dt3",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 1,
					image = "dl#dl_d4.png",
					scale9Left = 0.4,
					scale9Right = 0.4,
					scale9Top = 0.4,
					scale9Bottom = 0.4,
				},
			},
			},
		},
		{
			prop = {
				etype = "Image",
				name = "dt2",
				varName = "selectImg",
				posX = 0.450372,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				visible = false,
				sizeX = 0.9181143,
				sizeY = 1.125,
				image = "dl#dl_d2.png",
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "tx2",
				varName = "headBg",
				posX = 0.1589888,
				posY = 0.4722221,
				anchorX = 0.5,
				anchorY = 0.5,
				lockHV = true,
				sizeX = 0.3647643,
				sizeY = 0.9833332,
				image = "zdtx#txd",
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tx1",
					varName = "head",
					posX = 0.5054789,
					posY = 0.6925332,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.7210885,
					sizeY = 1.110169,
				},
			},
			},
		},
		{
			prop = {
				etype = "Label",
				name = "wz1",
				varName = "labName",
				posX = 0.6274095,
				posY = 0.6827407,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.6526849,
				sizeY = 0.3904214,
				text = "名字一共就八个字",
				color = "FF36180E",
				fontSize = 24,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj1",
				varName = "labLvl",
				posX = 0.5791375,
				posY = 0.3274559,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2484475,
				sizeY = 0.3904214,
				text = "Lv.99",
				color = "FF440078",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Image",
				name = "bz1",
				varName = "imgClass",
				posX = 0.6908264,
				posY = 0.3274559,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.1116626,
				sizeY = 0.3749999,
				image = "zy#daoke",
			},
		},
		{
			prop = {
				etype = "Label",
				name = "dj2",
				varName = "typeLabel",
				posX = 0.4302535,
				posY = 0.3274561,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.2484475,
				sizeY = 0.3904214,
				text = "中立",
				fontSize = 22,
				fontOutlineColor = "FF102E21",
				vTextAlign = 1,
			},
		},
		{
			prop = {
				etype = "Button",
				name = "an",
				varName = "selectBtn",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 1,
				sizeY = 1,
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
