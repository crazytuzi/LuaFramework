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
			name = "d13",
			varName = "BatterEquipRoot",
			posX = 0.5,
			posY = 0.5,
			anchorX = 0.5,
			anchorY = 0.5,
			sizeX = 0.1647134,
			sizeY = 0.3375,
			layoutType = 5,
			layoutTypeW = 5,
		},
		children = {
		{
			prop = {
				etype = "Image",
				name = "dt8",
				varName = "BatterEquipPanel",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.7114631,
				sizeY = 0.9053498,
				image = "b#zbd",
				scale9 = true,
				scale9Left = 0.4,
				scale9Right = 0.4,
				scale9Top = 0.4,
				scale9Bottom = 0.4,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "djdt3",
					varName = "EquipItem_bg",
					posX = 0.5087607,
					posY = 0.6160802,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.6266667,
					sizeY = 0.4272727,
					image = "djk#ktong",
				},
				children = {
				{
					prop = {
						etype = "Image",
						name = "djt3",
						varName = "icon",
						posX = 0.4942023,
						posY = 0.509545,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8,
						sizeY = 0.8,
						image = "items#chutou",
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "gn7",
					varName = "fishBtn",
					posX = 0.5,
					posY = 0.4011326,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1,
					sizeY = 0.8022652,
					propagateToChildren = true,
					soundEffectClick = "audio/rxjh/UI/anniu.ogg",
				},
				children = {
				{
					prop = {
						etype = "Button",
						name = "dj",
						posX = 0.5,
						posY = 0.2761286,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.8266667,
						sizeY = 0.328615,
						image = "chu1#sn1",
						scale9Left = 0.4,
						scale9Right = 0.4,
						imageNormal = "chu1#sn1",
						disableClick = true,
					},
				},
				{
					prop = {
						etype = "Label",
						name = "gnmz7",
						varName = "BtnLabel",
						posX = 0.4999998,
						posY = 0.2761287,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9458116,
						sizeY = 0.4058827,
						text = "钓 鱼",
						fontSize = 24,
						fontOutlineEnable = true,
						fontOutlineColor = "FF8F4E1B",
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
	},
	},
}
--EDITOR elements end tag
--EDITOR animations start tag
local l_animations =
{
	gy = {
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
