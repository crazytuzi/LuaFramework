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
			image = "b#dd",
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
	{
		prop = {
			etype = "Grid",
			name = "ysjm",
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
				etype = "Image",
				name = "dt",
				posX = 0.5,
				posY = 0.5,
				anchorX = 0.5,
				anchorY = 0.5,
				sizeX = 0.3617434,
				sizeY = 0.3509443,
				scale9 = true,
				scale9Left = 0.45,
				scale9Right = 0.45,
				scale9Top = 0.25,
				scale9Bottom = 0.7,
			},
			children = {
			{
				prop = {
					etype = "Image",
					name = "tsbj",
					varName = "background",
					posX = 0.5,
					posY = 0.5,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.185664,
					sizeY = 2.232073,
					image = "jqchunjie#jqchunjie",
				},
			},
			{
				prop = {
					etype = "Image",
					name = "smd",
					varName = "descTxtBg",
					posX = 0.5,
					posY = 0.6857004,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8902511,
					sizeY = 0.395105,
					scale9 = true,
					scale9Left = 0.45,
					scale9Right = 0.45,
					scale9Top = 0.45,
					scale9Bottom = 0.45,
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "xy",
						varName = "descTxt",
						posX = 0.5,
						posY = 0.640231,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 0.9636856,
						sizeY = 2.003304,
						text = "节气描述语",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineSize = 2,
						hTextAlign = 1,
						vTextAlign = 1,
					},
				},
				},
			},
			{
				prop = {
					etype = "Button",
					name = "a2",
					varName = "SureBtn",
					posX = 0.5,
					posY = -0.1527496,
					anchorX = 0.5,
					anchorY = 0.5,
					lockHV = true,
					sizeX = 0.3416221,
					sizeY = 0.2374546,
					image = "chu1#an2",
					imageNormal = "chu1#an2",
					disablePressScale = true,
					soundEffectClick = "audio/rxjh/UI/ui_guanbi.ogg",
				},
				children = {
				{
					prop = {
						etype = "Label",
						name = "wz2",
						varName = "normalText",
						posX = 0.4999996,
						posY = 0.5,
						anchorX = 0.5,
						anchorY = 0.5,
						sizeX = 1.635371,
						sizeY = 1.85732,
						text = "确 定",
						fontSize = 22,
						fontOutlineEnable = true,
						fontOutlineColor = "FF347468",
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
					name = "jqt",
					varName = "solarTermIcon",
					posX = 0.5,
					posY = 1.0571,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 1.289329,
					sizeY = 1.127909,
					image = "lichun#lichun",
				},
			},
			{
				prop = {
					etype = "Scroll",
					name = "lb",
					varName = "bonusScroll",
					posX = 0.503233,
					posY = 0.272094,
					anchorX = 0.5,
					anchorY = 0.5,
					sizeX = 0.8258008,
					sizeY = 0.4213322,
					horizontal = true,
					showScrollBar = false,
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
	dk = {
		ysjm = {
			scale = {{0, {0.3, 0.3, 1}}, {150, {1.05, 1.05, 1}}, {200, {1,1,1}}, },
		},
	},
	c_dakai = {
		{0,"dk", 1, 0},
	},
}
--EDITOR animations end tag
local function create()
return UIUtil.createNode(l_fileType, eleRoot, l_animations)
end
return create
